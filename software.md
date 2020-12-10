---
layout: page
title: Software
subtitle: Software
permalink: /software/
---

## Stata coding guide
My [Stata Coding Guide](/guide) describes how to set up a robust coding environment and write a "push-button" analysis in Stata. It includes a companion [sample replication package](https://github.com/reifjulian/my-project) that provides a template for publishing data and code.

## Software packages
Source code and installation instructions for my software packages are available on [GitHub](https://github.com/reifjulian). To install the latest version of all the Stata packages, execute [this script](/software/install_all.do). The Stata packages can also be installed using the `ssc` command. For example, type `ssc install regsave, replace` at the Stata prompt to install the `regsave` package.

{:class="table table-bordered " style="vertical-align: middle"}
| Package      | Language | Description |
| -------      | -------- | ----------- |
| `TextFileLoad` | C++ | `TextFileLoad` is an ANSI-compliant class that enables programs to import data from text files in a user-friendly manner. Data can be loaded by column name or number and are automatically converted to the appropriate data types. |
| `appendfile` | Stata | `appendfile` appends a text file to another text file. |
| `autorename` | Stata | `autorename` renames variables using a row of data. This can be useful when reading oddly formatted datasets. |
| `regsave` | Stata | `regsave` stores regression output into a Stata-formatted dataset. |
| `rscript` | Stata | `rscript` calls an R script from Stata. |
| `sortobs` | Stata | `sortobs` allows the user to sort observations by variable values or observation numbers. |
| `strgroup` | Stata/C | `strgroup` matches strings based on their Levenshtein edit distance. |
| `svret` | Stata | `svret` replaces the dataset in memory with the scalars and macros stored in `e()`, `r()`, and `s()`. |
| `texsave` | Stata | `texsave` outputs the dataset currently in memory to a file in LaTeX format. |
| `wyoung` | Stata | `wyoung` controls the family-wise error rate when performing multiple hypothesis tests by estimating adjusted p-values using the free step-down resampling methodology of Westfall and Young (1993). |


## Supplementary materials for `wyoung`
Additional documentation for `wyoung` is available [here](/wyoung/documentation/wyoung.pdf). The accompanying Stata code for the simulations reported in that documentation is available [here](/wyoung/documentation/simulations/wyoung_simulations.do).
