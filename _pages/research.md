---
title: Research
permalink: /research/
layout: splash
---

{: style="display: flex; justify-content: space-evenly"}
[Research statement](/research/reif.research.2020.05.pdf)
[Google Scholar](https://scholar.google.com/citations?user=Tpe9XEcAAAAJ)

<div class="card">

  {% assign datasets = "publications, publications-working, publications-chapters, publications-other" | split: ", " %}
  
  {% for ds in datasets %}
  
    <div class="jumbotron text-center">
      <h2>
      {% if ds == 'publications' %} Publications {% endif %}
	  {% if ds == 'publications-working' %} Working papers {% endif %}
	  {% if ds == 'publications-chapters' %} Book chapters {% endif %}
	  {% if ds == 'publications-other' %} Other publications{% endif %}
	  </h2>
    </div>
    
    {% for item in site.data[ds] %}
    
      <div class="card-body">
        <p class="card-text">
	  	<b>{{ item.title }} </b><br>
	  	  
	  	{% if item.coauthors != blank %} with {{ item.coauthors }} <br> {% endif %}
	  	  
	  	{% if item.publication != blank %} {{ item.publication | replace_first: '*', '<span style="color:FireBrick"><em>' | replace_first: '*', '</em></span>' }} <br>  {% endif %}
	  	
	  	{% if item.award != blank %} {{ item.award | markdownify | remove:'<p>' | remove:'</p>'}} <br>  {% endif %}
    
	  	{% for m in item.media %}
	  	  {% if forloop.first %} Media: {% endif %}
	  	  {% if forloop.last %} {{ m | markdownify | remove:'<p>' | remove:'</p>'}} <br> 
	  	  {% else %} {{ m | markdownify | remove:'<p>' | remove:'</p>' | rstrip | append: ', '}}
	  	  {% endif %}	
	  	{% endfor %}
    
	  	{% for p in item.policy %}
	  	  {% if forloop.first %} Policy: {% endif %}
	  	  {% if forloop.last %} {{ p | markdownify | remove:'<p>' | remove:'</p>'}} <br> 
	  	  {% else %} {{ p | markdownify | remove:'<p>' | remove:'</p>' | rstrip | append: ', '}}
	  	  {% endif %}	
	  	{% endfor %}		
    
	  	{% for o in item.other %}
	  	  {{ o | markdownify | remove:'<p>' | remove:'</p>'}}
	  	  {% if forloop.last %} <br> 
	  	  {% else %} |
	  	  {% endif %}		  
	  	{% endfor %}		  
    
	  	{% if item.abstract != blank %}
	  	  <details>
	  		<summary style="margin-top: -1.3em; ">Abstract</summary>
	  		<p class="notice" style="margin-top:0 !important">{{ item.abstract }}</p>
	  	  </details>
	  	{% endif %}
	    </p>
      </div>
    {% endfor %}
  
  {% endfor %}
  
  <!-- WORKS IN PROGRESS -->
  <div class="jumbotron text-center">
    <h2>Works in progress</h2>
  </div>
  <div class="card-body">

   "Peer Effects in the Workplace: Evidence from the Illinois Workplace Wellness Study" (with Damon Jones and David Molitor)<br><br>

   "Pollution and Mortality in the United States: Evidence from 1972-1988" (with Tatyana Deryugina)<br><br>

   "Does Medicare Improve Quality of Life?"<br><br>

   "Evasion or Stockpiling? The Effect of Anticipated Future Tax Changes on Gasoline Sales" (with Don Fullerton)<br>
  </div>
  
  
  <!-- EXTERNAL GRANTS -->
  <div class="jumbotron text-center">
    <h2>External grants</h2>
  </div>
  
  {% for item in site.data.publications-grants %}
    <div class="card-block">
	<b>{{ item.title }}</b> <br>
    {{ item.role }}, with {{ item.coauthors }} <br>
	
	{% if item.details != blank %}
      {{ item.details }} <br> 
      {{ item.amount }} <br>
      {% if forloop.last == false %} <br> {% endif %}
    {% else %}
      {{ item.amount }} <br>
      <table style="padding:0px; border-collapse: collapse">
      {% for g in item.other %}
        <tr style="border-style:hidden">
        <td style="text-indent:25px">{{ g.entity }}, </td>
        {% if g.number != blank %} <td align="left">{{ g.number }},</td>{% endif %}
        <td align="left">{{ g.date }},</td>
        <td align="left">{{ g.amount }}</td>
        </tr>
      {% endfor %}
      </table>		
	{% endif %}
    </div>
  {% endfor %}
  
</div>



