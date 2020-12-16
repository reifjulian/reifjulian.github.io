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
<table>
  {% for row in site.data.software %}
    {% if forloop.first %}
	<thead>
    <tr>
      {% for pair in row %}
        <th>{{ pair[0] | font_modify: 'weight', 'bold'}}</th>
      {% endfor %}
    </tr>
	</thead>
    {% endif %}


    {% tablerow pair in row %}
      {{ pair[1] | markdownify}}
    {% endtablerow %}
  {% endfor %}
</table>


## Supplementary materials for wyoung
Additional documentation for `wyoung` is available [here](/wyoung/documentation/wyoung.pdf). The accompanying Stata code for the simulations reported in that documentation is available [here](/wyoung/documentation/simulations/wyoung_simulations.do).
