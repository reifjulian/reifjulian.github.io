---
layout: post
title:  "Writing my first Stata plugin: A real world use case"
date:   2017-02-14 20:13:24 -0500
categories: stata plugins
---


<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      processEscapes: true
    }
  });
</script>
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>

I'm not the biggest fan of Stata. Though I use it every day for RA work,
and Stata does shine when all you want to do is explore one data set (or
a series of data sets that are easy to merge), it's become increasingly
apparent over time that whenever I want to do something complex or
computationally intensive, it pales.

[Mata](www.stata.com/features/overview/introduction-to-mata/) makes many
of the rougher corners of Stata rather bearable. However, optimizing
Stata for a speedy run is really difficult. Enter [Stata plugins](www.stata.com/plugins/).

What are Stata plugins?
-----------------------

A Stata plugin is pre-recompiled code, written in C or C++, that can
interact with Stata using the "Stata Plugin Interface (SPI)." Stata
provides a C source file and header that allows a C program to interact
with Stata's data sets and matrices.

The implementation is relatively crude. Stata can write/read to/from
C one observation at a time from/to existing variables and matrices.
[Stata has pretty good documentation](www.stata.com/plugins/) for the
functionality of their plugins, and I will not repeat all of it here.

A simple hello world program would be as follows:
- Get a C compiler (`gcc`, the GNU Compiler Collection, is standard and should be included on Mac and Linux; look into [MinGW](http://www.mingw.org) if you are on Windows to use `gcc`).
- Download the Stata Splugin Interface (SPI) version 2 (Stata <= 13) or 3 (Stata >= 14).
    - Version 2: [stplugin.c](http://www.stata.com/plugins/version2/stplugin.c), [stplugin.h](http://www.stata.com/plugins/version2/stplugin.h)
    - Version 3: [stplugin.c](http://www.stata.com/plugins/stplugin.c), [stplugin.h](http://www.stata.com/plugins/stplugin.h)
- Create hello.c (Note you should have stplugin.h and stplugin.c in the same directory).

{% highlight C %}
#include "stplugin.h"

STDLL stata_call(int argc, char *argv[])
{
    SF_display ("Hello World\n");
    return (0);
}
{% endhighlight %}

- Now from the command line, run
{% highlight bash %}
gcc -shared -fPIC -DSYSTEM=OPUNIX stplugin.c hello.c -o hello.plugin # Linux
gcc -bundle -DSYSTEM=APPLEMAC stplugin.c hello.c -o hello.plugin     # Mac
{% endhighlight %}

- Last, from Stata navigate to your working directory and run
{% highlight stata %}
program hello, plugin using("./hello.plugin")
plugin call hello
{% endhighlight %}

Is it worth the hassle?
-----------------------

Stata says that it's only worth it if you are replacing a lot of interpreted
ado-code and the task is not very complex. Though I agree on the latter
(complex tasks will likely take more time to code in C than the time they
will save) I _strongly_ disagree on the former.

Perhaps most people realize this, but my understanding of for loops in
Stata is that they are run as if you printed each block within the for
loop however many times you tell it to execute. Thus

{% highlight stata %}
forvalues i = 1 / 1000 {
    // Stuff to do
}
{% endhighlight %}

may look like three lines of code, but it's really equivalent to 1000.
The reason I started using Stata plugins was to speed up a simulation.
The C code is longer and the base case are only a handful of lines in
Stata, but it's painfully slow because the bulk of the computation takes
place inside a loop that does a simulation.

Below I document a real-world use case where C was 50 times faster than
Stata, so for me the work was definitely worthwhile.

A real world use case
---------------------

Several of the projects I work on are Randomized Control Trials. It is
standard to conduct a power analysis for such projects in order to put
together a proposal, etc. Having a well-powered trial is essential for
the success of an RCT.

Since RCTs can give you a truly independent treatment variable, we can
recover the treatment effect via simple OLS. Though parametric methods
are well known and widely used to estimate power under this setup,
they rely on strong assumptions. When clustering or stratification are
involved, specially when the number of clusters is not very large,
parametric calculations can be inaccurate.

One suggestion I got was to _simulate_ power. I won't outline the full
rationale ([read about it here](https://github.com/mcaceresb/stata-power/blob/master/notes/power-simulation-notes.pdf)), but the crux of the idea is to simulate a large number of
coefficients $b$ for the equation:

$$Y_{ij} = a + b T_{ij} + g X_{ij} + e_{ij}$$

where at each step of the simulation, $T_{ij}$ is simulated so that
there are $NP$ individuals/clusters in treatment and $(1 - P)N$
in control. Since treatment is assigned randomly, the resulting
distribution is a sample of the true distribution of $b$ under the null
$H_0: b = 0$.

This does not tell us anything about power by itself, but the confidence
interval can be used as the basis of an iterative procedure to simulate
power. Hence coding the simulation efficiently is crucial.

Why write a plugin?
-------------------

The problem above is actually very simple to implement. In pseudo-code:
{% highlight stata %}
function simci (X, y, P, reps)
{
    n = rows(X)
    b = zeros(reps)
    T = ones(ceil(n * P)) \ zeros(floor(n * (1 - P)))

    for (r = 1; r <= reps; r++)
    {
        XT   = shuffle(T), X
        b[r] = (inv(XT' * XT) * (XT' * y))[1]
    }

    return (b)
}
{% endhighlight %}

Though simple, doing this _**efficiently**_ is impossible in
Stata. There are three prominent issues:
1. There is no way to shuffle a vector in Stata. That's not a thing.
   Variables all exist in relation to each other and sorting one
   variable randomly will sort the entire data set. Shuffling an entire
   data set is much slower than shuffling one vector.

2. There is no way to compute just the regression coefficients in Stata.
   Stata's `regress` computes a host of things along with the least
   squares solution This adds unnecessary overhead. (I have asked about
   how to do this before; the suggestion I got was to run `quietly
   regress, notable` which just controls what Stata outputs, not what it
   computes).

3. It's not obvious how to store the results, specially with Stata/IC.
   Though the buffer versions of Stata should be able to handle most
   simulations after setting a larger `matsize`, the fact matrix sizes
   are capped (and in Stata/IC capped at 800), makes the function
   difficult to code.

The solution in Stata would look like this
{% highlight stata %}
program stataSimci, rclass sortpreserve
    syntax varlist [if] [in] , [ Ptreat(real 0.5) reps(int 100) ]

    gettoken depvar controls: varlist
    marksample touse
    _rmcoll `controls' if `touse'
    local controls `r(varlist)'

    qui {
    preserve
        keep if `touse'
        local NP = ceil(`=_N' * `ptreat')

        tempname b
        tempvar treatment randsort
        gen byte   `treatment' = .
        gen double `randsort'  = .

        forvalues r = 1 / `reps' {
            replace `randsort'  = runiform()
            sort `randsort'
            replace `treatment' = (_n <= `NP')
            regress `depvar' `treatment' `controls' if `touse'
            matrix `b' = nullmat(`b') \ `:di _b[`treatment']'
        }
    restore
    }

    return matrix b = `b'
end

sysuse auto, clear
stataSimci price mpg foreign, p(0.5) reps(10)
matrix list r(b)
{% endhighlight %}

This is a hugely inefficient program!

Wait, can't Mata handle these things?
-------------------------------------

Right, Mata is the elephant in the room. If you don't know,
[Mata](http://www.stata.com/features/overview/introduction-to-mata/) is
a programming language that is shipped with every version of Stata and
it can interact with Stata relatively easily. If you have ever used an
object-oriented programming language then you will recognize Mata as a
more standard programming language than Stata.

Mata does afford us _some_ efficiency, but not a lot (yes, I know about
`.mlib` files and that technically Stata compiles mata into bytecode
when read into memory, but I have never found the speed improvement to
be significant).

In this case, Mata will run faster largely because it can
1. Shuffle just a single vector.

2. Get the OLS coefficients without any additional computations.

The implementation is very straightforward:

{% highlight stata %}
program mataSimci, rclass sortpreserve
    syntax varlist [if] [in] , [ Ptreat(real 0.5) reps(int 100) ]
    gettoken depvar controls: varlist
    marksample touse
    _rmcoll `controls' if `touse'
    local controls `r(varlist)'
    mata: b = simci("`depvar'", "`controls'", "`touse'", `ptreat', `reps')
    mata: st_matrix("b", b)
    return matrix b = b
end

mata:
real colvector function simci(string scalar depvar,
                              string scalar controls,
                              string scalar touse,
                              real scalar P,
                              real scalar reps)
{
    real scalar n
    real colvector b, T, y
    real matrix X

    y = X = .
    st_view(y, ., depvar,   touse)
    st_view(X, ., controls, touse)

    n = rows(X)
    b = J(reps, 1, missingof(X))
    T = J(ceil(n * P), 1, 1) \ J(floor(n * (1 - P)), 1, 0)

    for (r = 1; r <= reps; r++)
    {
        XT   = (jumble(T), X)
        b[r] = (invsym(cross(XT, 1, XT, 1)) * cross(XT, 1, y, 0))[1]
    }

    return(b)
}
end

sysuse auto, clear
mataSimci price mpg foreign, p(0.5) reps(10)
matrix list r(b)
{% endhighlight %}

There are two problems:
1. Matrix operations in Mata are not terribly fast (certainly not
   compered to a compiled language like C or even a JIT-compiled
   language like Julia). Yes, I know Mata uses LAPACK and BLAS
   underneath, but it's still largely an interpreted language.

2. There is no reason to run the loop sequentially! It is conceptually
   trivial to parallelize the loop. Granted, parallelism is not trivial
   but the fact it cannot be done, even in Stata/MP, is frustrating.

How does the solution in C look like?
-------------------------------------

C is certainly harder to write, and Stata's primitive interaction with
C makes it so getting the results back from C is annoying. BUT there is
a MASSIVE speed improvement. For this particular use case it's an order
of magnitude (around 10x) over Mata (and that implementation was already
faster than Stata).

Writing the wrapper for this is not too hard thanks to the GNU
Scientific Library. Noting the 0-based indexing:

{% highlight C %}
#include <math.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_matrix_double.h>
#include <gsl/gsl_permutation.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_rng.h>
#include "stplugin.h"

// These functions are to be used after reading Stata data into X, y.
// Crucially, in this example the first column of X must be empty.

int simci (const gsl_matrix * X,
           const gsl_vector * y,
           const double P,
           const int reps,
           gsl_vector * b);
double sim_ols(const gsl_matrix * X, const gsl_vector * y);

// This function would read the data from stata
STDLL stata_call(int argc, char *argv[])
{

    // Initialize the variables to use
    ST_int      i, j ;
    ST_double   z ;
    ST_retcode  rc ;

    // Get P and number of reps. Note the 0-based indexing! So the
    // functiona ssumes P and reps were the 2nd and 3rd argument.
    double P    = strtod (argv[1], NULL);
    double reps = strtod (argv[2], NULL);

    const size_t n = SF_in2();
    const int    k = SF_nvars();
    gsl_matrix *X  = gsl_matrix_alloc (n, k + 1);
    gsl_vector *y  = gsl_vector_alloc (n);

    // Not sure if there is another way to read data vs the double loop.
    // Again, careful with the 0-based indexing!
    for (i = SF_in1(); i <= SF_in2(); i++) {
        if (SF_ifobs(i)) {

            // Variables 2 through k are covariates
            for (j = 2; j <= k; j++) {
                // Note we leave the first column empty
                if ( (rc = SF_vdata(j, i, &z)) ) return(rc);
                gsl_matrix_set (X, i - 1, j - 1, z);
            }

            // Note we add the constant
            gsl_matrix_set (X,  i - 1, k, 1.0);

            // Variable 1 is the dependent variable
            if ( (rc = SF_vdata(1, i, &z)) ) return(rc);
            gsl_vector_set (y,  i - 1, z);
        }
    }

    // Now we call the simulation function and output the results into b
    gsl_vector *b = gsl_vector_alloc (reps);
    simci (X, y, P, reps, b);

    gsl_matrix_free (X);
    gsl_vector_free (y);

    // Note the first argument passed to the plugin call must be the
    // name of a matrix that exists in Stata.
    for (i = 0; i < b->size; i++) {
        SF_mat_store (argv[0], i + 1, 1, gsl_vector_get (b, i));
    }

    // The method above is a hassle because Stata limits matrix size and
    // the matrix has to exist. Some workarounds:
    // - Space-delimited local macro, then read using mata: tokens()
    // - Write to a temporary file then read using mata: cat()

    return (0);
}

// This will output the results into b
int simci (const gsl_matrix * X,
           const gsl_vector * y,
           const double P,
           const int reps,
           gsl_vector * b)
{

    const size_t n = X->size1;
    const int k    = X->size2;
    const int np   = ceil(n * P);

    // Set the random seed based on the time of day (seconds)
    srand (time(NULL));
    gsl_rng *rng = gsl_rng_alloc (gsl_rng_default);
    gsl_rng_set (rng, rand());

    // Get vector of 1s and 0s
    gsl_vector *T = gsl_vector_alloc (n);
    gsl_vector_set_zero (T);
    for (int i = 0; i < np; i++) {
        gsl_vector_set (T, i, 1.0);
    }

    // Initialize elements for parallel loop
    gsl_vector *Tp ;
    gsl_matrix *Xp ;

    // Parallelize execution
    #pragma omp parallel private(Xp, Tp) shared(y, b)
    {
        // Allocate to each therad their own copy
        Tp = gsl_vector_alloc (n);
        Xp = gsl_matrix_alloc (n, k);

        gsl_vector_memcpy (Tp, T);
        gsl_matrix_memcpy (Xp, X);

        // Parallel for loop through simulation
        #pragma omp for
        for (int r = 0; r < reps; r++) {
            gsl_ran_shuffle (rng, Tp->data, n, sizeof(size_t));
            gsl_matrix_set_col (Xp, 0, Tp);
            gsl_vector_set (b, r, sim_ols(Xp, y));
        }

        // Cleanup
        gsl_matrix_free (Xp);
        gsl_vector_free (Tp);
    }

    // Cleanup
    gsl_vector_free (T);
    gsl_rng_free (rng);

    return (0);
}

double sim_ols(const gsl_matrix * X, const gsl_vector * y)
{

    // Allocate memory to express the system as Ax = b
    gsl_matrix *A = gsl_matrix_alloc (X->size2, X->size2);
    gsl_vector *b = gsl_vector_alloc (X->size2);
    gsl_vector *x = gsl_vector_alloc (X->size2);

    // Set A = X' X and b = X' y
    gsl_blas_dgemm (CblasTrans, CblasNoTrans, 1.0, X, X, 0.0, A);
    gsl_blas_dgemv (CblasTrans, 1.0, X, y, 0.0, b);

    // Cholesky decomposition
    gsl_linalg_cholesky_decomp1 (A);
    gsl_linalg_cholesky_solve (A, b, x);

    // Cleanup
    gsl_matrix_free (A);
    gsl_vector_free (b);

    return (gsl_vector_get(x, 0));
}
{% endhighlight %}

Save the code to `pluginSimci.c`. To compile `pluginSimci.plgin`, on top
of `gcc` and the SPI, you will need
- The [GNU Scientific Library (GSL)](https://www.gnu.org/software/gsl)
- [OpenMP](http://www.openmp.org)

Again, you should have `stplugin.c` and `stplugin.h` in the same directory. Now on Linux/Unix, run
{% highlight bash %}
CFLAGS="-Wall -fopenmp -shared -fPIC -DSYSTEM=OPUNIX"
gcc $CFLAGS -c -o stplugin.o    stplugin.c
gcc $CFLAGS -c -o pluginSimci.o pluginSimci.c
gcc $CFLAGS stplugin.o pluginSimci.o \
    -lgsl -lgslcblas -lm -o pluginSimci.plugin
{% endhighlight %}

Depending on your system, you may also need to add `-std=c99` as a flag and point to the location of the `libgsl*so` files. For instance, I regularly SSH into a RedHat server, and to compile I ran
{% highlight bash %}
CFLAGS="-Wall -std=c99 -fopenmp -shared -fPIC -DSYSTEM=OPUNIX"
gcc -I/usr/local/lib $CFLAGS -c -o stplugin.o    stplugin.c
gcc -I/usr/local/lib $CFLAGS -c -o pluginSimci.o pluginSimci.c
gcc -L/usr/local/lib $CFLAGS  stplugin.o pluginSimci.o \
    -lgsl -lgslcblas -lm -o pluginSimci.plugin
{% endhighlight %}

To compile in other system, you should consult [Stata's documentation](http://www.stata.com/plugins). Once compiled, from Stata:

{% highlight stata %}
matrix b = J(10, 1, .)
sysuse auto
program pluginSimci, plugin using(./pluginSimci.plugin)
plugin call pluginSimci price mpg foreign, b 0.5 10
matrix list b
{% endhighlight %}

Timing performance
------------------

I don't really know of good Stata tools to profile performance. However,
it's not too hard to time how long a command takes to run. I wrote a
simple wrapper for it, which we use with the programs above:

{% highlight stata %}
. local github https://raw.githubusercontent.com
. net install benchmark, from(`github'/mcaceresb/stata-benchmark/master/)
. local benchmark benchmark, disp reps(5): qui

. set seed 42
. set matsize 800
. sysuse auto, clear
. tempfile auto
. save `auto'
. qui forvalues i = 1 / 100 {
.     append using `auto'
. }

. `benchmark' stataSimci  price mpg foreign, p(0.5) reps(800)
1: 10.52 seconds
2: 9.143 seconds
3: 12.13 seconds
4: 14.25 seconds
5: 12.54 seconds
Average over 5 runs: 11.7166 seconds

. `benchmark' mataSimci  price mpg foreign, p(0.5) reps(800)
 2.546 seconds
 2.692 seconds
 2.68 seconds
 2.368 seconds
 2.426 seconds
Average over 5 runs: 2.5424 seconds

. matrix b = J(800, 1, .)
. `benchmark' plugin call pluginSimci price mpg foreign, b 0.5 800
1: .283 seconds
2: .273 seconds
3: .262 seconds
4: .238 seconds
5: .288 seconds
Average over 5 runs: 0.2688 seconds
{% endhighlight %}

In the example Mata ran 5x vs Stata and the plugin ran 10x vs Mata. For
a 50x speed improvement, I'd say the hassle was worth it! My real-world
use-case for this was power simulations for a cluster-randomized trial
where the underlying clusters were comprised of 200k observations
overall. Running this in Mata took on the order of days. To have it run
in hours was a massive boon.
