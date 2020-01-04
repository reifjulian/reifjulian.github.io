---
layout: guide
title: Stata Coding Guide
subtitle: Guide
permalink: /guide/
---

# Managing an analysis in Stata
{:.no_toc}
Author: [Julian Reif](http://www.julianreif.com), University of Illinois

This guide describes how to put together a publication-quality analysis in Stata. Following this guide will help:
1. Minimize coding errors during analysis
1. Automate the creation of tables and figures
1. Produce a replication folder suitable for publication

Two simple examples of polished analyses accompany this guide. You can download and run those analyses yourself to assess how easy (or not!) it is to replicate them. The first example assumes you have a working installation of Stata. The second assumes you also have a working installation of R.
1. Example 1: Simple Stata analysis that produces figures and LaTeX tables
1. Example 2: Same as example 1, but also incorporates a supplemental R analysis automated in Stata

1. toc1
{:toc}


-----------

## Overview 

## Setting up your environment

I generally work on many projects at the same time and access them from different computers (laptop, home, work, etc.). A working project needs to be synced across my computers, and the analysis code must allow the project folder to have a different path on the different computers.  

### Dropbox

I use Dropbox to sync my projects across different computers. Dropbox has several appealing features. It creates backups of my projects across multiple computers and the Dropbox server, and in my experience has fewer bugs than alternatives such as Box. Dropbox makes it easy to share files with coauthors. Finally, all files inside of Dropbox have the same relative paths, which is helpful when writing scripts (more on this below).

### Stata profile

Stata automatically runs `profile.do` upon launch. 

`profile.do` must be stored in one of the paths searched by Stata. Type `adopath` at the Stata prompt to view a list of the paths for your particular computer.

Here is my Stata profile, stored in `C:/ado/personal/profile.do`:
```stata
* Settings specific to local environment
global DROPBOX "C:/Users/jreif/Dropbox"
global RSCRIPT_PATH "C:/Program Files/R/R-3.6.2/bin/x64/Rscript.exe"

* Run file containing settings common to all environments
run "$DROPBOX/stata_profile.do"
```

This file contains settings specific to my computer, such as the location of Dropbox and my *R* installation. I could define my project directories here. But instead, I store those in `$DROPBOX/stata_profile.do`, along with any other settings that are common across my computers:

```stata
set varabbrev off
global MyProject "$DROPBOX/my_project"
```

In this example I have defined the location of only one project, `MyProject`. In practice I have a large number of globals defined here, one for every project I am working on. Whenever I start a new project, I define a new global for it and add it to `$DROPBOX/stata_profile.do`. Because all my computers are synced to Dropbox, I only have to do this once.

*Stata runs your profile automatically on startup*<br>
<img src="/assets/guide/stata_profile.PNG" width="50%" title="Stata profile">

### *R* profile

*R* automatically runs `Rprofile.site` upon launch. On Windows, this file is located in the `C:/Program Files/R/R-n.n.n/etc` directory.  Alternatively you can store these settings in .Rprofile, which is run after Rprofile.site. Type `.libPaths()` at the R prompt to view a list of the paths for your particular computer.

```R
# Settings specific to local environment
Sys.setenv(DROPBOX = "C:/Users/jreif/Dropbox")

# Run file containing settings common to all environments
source(file.path(Sys.getenv("DROPBOX"), "R_profile.R"))
```

Store your general *R* settings on Dropbox. Store this file `R_profile.R` at the top level of your Dropbox folder. Define the paths for all your projects here. In this example, we have defined the location for one project, `MyProject`.


## Organizing the project

### Folder structure

```text
.
└── analysis
    └── data
        ├── proc
        └── raw
    └── results
        ├── figures
        └── tables
    └── scripts
        ├── 0_run_all.do
        └── 1_...
└── paper
    ├── manuscript.tex
    ├── figures
    └── tables

```


The top level of a project directory should always contain at least two folders. `analysis` includes all relevant scripts, data, and results. When the project is complete, a copy of `analysis` can serve as a standalone replication package. (All you have to change is where the project global points to.) `paper` contains manuscript files. Additional documents such as literature references can be stored there or in a separate folder at the top of project directory.

The analysis folder contains three subfolders. `analysis/scripts` stores all necessary scripts and libraries to run the entire project analysis from beginning to end. `analysis/data` includes all data, both raw and processed. `analysis/results` contains all final output, including tables and figures.


### Libraries

My code frequently employs user-written Stata commands, such as [regsave](https://github.com/reifjulian/regsave) or [reghdfe](http://scorreia.com/software/reghdfe/install.html). To ensure replication, it is **very important** to include a copy of these programs with your code:
1. Unless a user has a local copy of the program, she won't be able to run your code if you don't supply this program.
1. These commands are updated over time and newer versions may not work with older code implementations.

Many people do not appreciate how code updates can inhibit replication. Here is an example. You perform a Stata analysis using a new, user-written estimation command called, say, `regols`. You publish your paper, along with your replication code, but do not include the code for `regols`. 10 years later a researcher tries to replicate your analysis. The code breaks because she has not installed `regols`. She opens Stata and type `ssc install regols`, which installs the newest version of that command. But, in the intervening 10 years the author of `regols` fixed a bug in how the standard errors are calculated. When the researcher runs your code she finds your estimates are no longer significant. Is this because you included the wrong dataset with your replication, or because there is mistake in the analysis code, or because you failed to correctly copy/paste your output into your publication? The researcher does not know. She cannot replicate your published results and must now decide what to do.

When I start a new project, I include a script called `_install_stata_packages.do` that installs a copy of all required add-ons into a subdirectory of the project folder. Rerunning this script will install updated versions of these add-on's (if available). I delete the script when my project is ready to be published, which locks down the code for these packages and ensures I can replicate my analysis forever.

In theory, one can also install copies of add-on packages for *R* in your local project folder. In practice, I run into difficulties. Standard add-ons such as `tidyverse` have file sizes of several hundreds of megabytes. Installing *R* libraries locally also frequently generates installation errors, or result in only partial installations. Packages such as [packrat](https://rstudio.github.io/packrat/) may provide better solutions. In my example, I include a script called `_install_R_packages.R` that installs these packages for the user. This solution requires an internet connection, and is also vulnerable to the replication challenges mentioned above.

Overall, I am confident that my Stata analyses will be forever replicable, provided that Stata remains in business. I am less confident about my *R* analyses.

## Replication checklist

Follow these steps before submitting your "final materials" to ensure replication.

1. Remove `_install_stata_packages.do` from `/scripts`. 

1. Disable all locally installed Stata programs not located in your Stata folder. (This will ensure that your analysis is actually using programs installed in your project subdirectory, rather than somewhere else on your machine.) On Windows, this can usually be done by renaming `c:/ado` to `c:/_ado`. You can test whether you succeeded as follows. Suppose you have a copy of `regsave` somewhere on your machine and also in your local project directory. Open up a new instance of Stata and type `which regsave`. Stata should report "command regsave not found". If not, Stata will tell you where the command is located, and you can then rename that folder by adding an underscore. 

1. Delete the `/data/proc` and `/results` folders.

1. Run `0_run_all.do`, which should rerun the entire analysis and regenerate all tables and figures.

1. Copy `/results/figures` and `/results/tables` to `paper`. 

1. Recompile the paper and check the nubmers.

Checking the numbers can be difficult and tedious. Include lots of asserts in your code when writing up your results to reduce errors. (See an example of an `assert` in `4_make_tables_figures.do`.) 

## Good Stata coding practice

Use forward slashes for pathnames (`$DROPBOX/project` not `$DROPBOX\project`). Backslashes are an escape character in Stata and can cause issues depending on what operating system you are running. Stick with forward slashes to ensure cross-platform compatibility.

Never use hard-coded paths like `C:/Users/jreif/Dropbox/MyProject`. All pathnames should reference a global variable defined in your Stata profile. This way, anybody can run the entire analysis from their own computer without having to edit any project scripts.

Include `set varabbrev off` in your Stata profile.  Most professional Stata programmers I know do this in order to avoid unexpected behaviors such as [this](https://www.ifs.org.uk/docs/stata_gotchasJan2014.pdf).


## Example

An example of a fully replicable analysis is available in the folder `MyProject`. Running the script `0_run_all.do` 

## Other helpful links

[Grant McDermott's data science lectures](https://github.com/uo-ec607/lectures)

[Roger Koenker's guide](http://www.econ.uiuc.edu/~roger/research/repro)



## Acknowledgments

The coding practices outlined in this guide have been developed and improved over many years and over the course of many coauthored projects. I would especially like to thank my frequent collaborators Tatyana Deryugina and David Molitor for providing many helpful suggestions that have improved my project management over the yeras.
