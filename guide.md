---
layout: guide
title: Guide
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

I generally work on many projects at the same time and access them from different computers (laptop, home, work, etc.). The project needs to be synced across my computers, and the analysis code must allow the project folder to have a different path on the different computers.  

### Dropbox

I use Dropbox to sync my projects across different computers. Dropbox has several appealing features. It creates backups of my projects across multiple computers and the Dropbox server, and in my experience has fewer bugs than alternatives such as Box. It makes it easy to share files with coauthors. Finally, all files inside of Dropbox have the same relative paths, which is helpful when writing scripts (more on this below).

### Stata profile

Stata automatically runs `profile.do` upon launch. 

`profile.do` must be stored in one of the paths searched by Stata. Type `adopath` at the Stata prompt to view a list of the paths for your particular computer.

Here is my Stata profile, stored in `C:/ado/personal/profile.do`:
```stata
* Settings specific to local environment
global Dropbox "C:/Users/jreif/Dropbox"
global R344_path "C:/Program Files/R/R-3.4.4/bin/x64/Rscript.exe"

* Run file containing settings common to all environments
run "$Dropbox/stata_profile.do"
```

This file contains settings specific to my computer, such as the location of Dropbox and my R installation. I could also define my project directories here. But instead, I store those in `$Dropbox/stata_profile.do`, along with any other settings that are common across my computers:

```stata
set varabbrev off
global MyProject "$Dropbox/my_project"
```

In this example I have defined the location of only one project, `MyProject`. In practice I have a large number of globals defined here, one for every project I am working on. Whenever I start a new project, I define a new global for it and add it to `$Dropbox/stata_profile.do`. Because all my computers are synced to Dropbox, I only have to do this one time. I do not need to repeat it for all my workstations.

*Stata runs your profile automatically on startup*<br>
<img src="/assets/guide/stata_profile.PNG" width="50%" title="Stata profile">

<div class="image-cropper">
    <img src="{{ "/assets/guide/stata_profile.PNG" }}"  />
</div>

<img src="/assets/guide/stata_profile.PNG" alt="hi" class="inline"/>

### R profile

R automatically runs `Rprofile.site` upon launch. On Windows, the file is in the `C:/Program Files/R/R-n.n.n/etc` directory.  Alternatively you can store these settings in .Rprofile, which is run after Rprofile.site. Type `.libPaths()` at the R prompt to view a list of the paths for your particular computer.

```R
# Settings specific to local environment
Sys.setenv(Dropbox = "C:/Users/jreif/Dropbox")

# Run file containing settings common to all environments
source(file.path(Sys.getenv("Dropbox"), "R_profile.R"))
```

Store your general R settings on Dropbox. Store this file `R_profile.R` at the top level of your Dropbox folder. Define the paths for all your projects here. In this example, we have defined the location for one project, `MyProject`.


## Organizing the project

### Folder structure

- `/analysis`
  -  `/data`
     -  `/raw`
     -  `/proc`
  -  `/results`
  -  `/scripts`

The top level of the project directory always contains at least two folders. `analysis` includes all relevant scripts, data, and results. When the project is complete, a copy of `analysis` can serve as a standalone replication package. (All you have to change is where the project global points to.) `paper` contains manuscript files. Additional documents such as literature references can be stored there or in a separate folder at the top of project directory.

The analysis folder contains three subfolders. `analysis/scripts` stores all necessary scripts and libraries to run the entire project analysis from beginning to end. `analysis/data` includes all data, both raw and processed. `analysis/results` contains all final output, including tables and figures.


### Libraries

My code frequently employs user-written Stata commands, such as [regsave](https://github.com/reifjulian/regsave) or [reghdfe](http://scorreia.com/software/reghdfe/install.html). To ensure replication, it is **very important** to include a copy of these programs with your code:
1. Unless a user has a local copy of the program, they won't be able to run your code without the copy.
1. These commands are updated over time and newer versions may not work with older code implementations.

Many people do not appreciate how user code updates can inhibit replication. Here is an example. You perform a Stata analysis using a new, user-written estimation command called, say, `regols`. You publish your paper, along with your replication code, but do not include the code for `regols`. 10 years later a researcher tries to replicate your analysis. The code breaks because she did has not installed `regols`. She opens Stata and type `ssc install regols`, which installs the newest version of that command. But, in the intervening 10 years the author of `regols` fixed a bug in how the standard errors are calculated. When the researcher runs your code she finds your estimates are no longer significant. Is this because you included the wrong dataset with your replication, or because there is mistake in the analysis code, or because you failed to correctly copy/paste your output into your publication? The researcher does not know. She cannot replicate your published results and must now decide what to do.

When I start a new project, I include a script called `install_stata_packages.do` that installs every 

## Replication checklist

Add `_` to `c:ado`. Type `which regsave` to check.

## Good Stata coding practice

Use forward slashes for pathnames (`$Dropbox/project` not `$Dropbox\project`). Backslashes are an escape character in Stata and can cause issues depending on what operating system you are running. Stick with forward slashes to ensure cross-platform compatibility.

Never use hard-coded paths like `C:/Users/jreif/Dropbox/MyProject`. All pathnames should reference a global variable defined in your Stata profile. This way, anybody can run the entire analysis from their own computer without having to edit any project scripts.

Include `set varabbrev off` in your Stata profile.  Most professional Stata programmers I know do this in order to avoid unexpected behavior. To give but one example:
https://www.ifs.org.uk/docs/stata_gotchasJan2014.pdf

## Example

An example of a fully replicable analysis is available in the folder `MyProject`. Running the script `master.do` 

## Other helpful links

[Grant McDermott's data science lectures](https://github.com/uo-ec607/lectures)

[Roger Koenker's guide](http://www.econ.uiuc.edu/~roger/research/repro)



## Acknowledgments

The coding practices outlined in this guide have been developed and improved over many years and over the course of many coauthored projects. I would especially like to thank my frequent collaborators Tatyana Deryugina and David Molitor for providing many helpful suggestions that have improved my project management over the yeras.
