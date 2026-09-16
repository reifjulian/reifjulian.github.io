---
title: Research
permalink: /research/
description: "Publications, working papers, book chapters, and grants by Julian Reif, covering the health effects of air pollution, Medicare, medical innovation, medical debt, and workplace wellness programs."
layout: splash
---

{: style="display: flex; justify-content: space-evenly"}
[Research statement](/research/reif.research.2020.05.pdf)
[Google Scholar](https://scholar.google.com/citations?user=Tpe9XEcAAAAJ)

<div class="card">

  {% assign datasets = "publications-working, publications, publications-chapters, publications-other" | split: ", " %}
  
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
	  	  
	  	{% if item.coauthors and item.coauthors != "" %} with {{ item.coauthors }} <br> {% endif %}
	  	  
	  	{% if item.publication and item.publication != "" %} {{ item.publication | replace_first: '*', '<span style="color:FireBrick"><em>' | replace_first: '*', '</em></span>' }} <br>  {% endif %}
	  	
	  	{% if item.award and item.award != "" %} {{ item.award | markdownify | remove:'<p>' | remove:'</p>'}} <br>  {% endif %}
    
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
    
	    </p>
	  	{% if item.abstract and item.abstract != "" %}
	  	  <details>
	  		<summary style="margin-top: -1.3em; ">Abstract</summary>
	  		<p class="notice" style="margin-top:0 !important">{{ item.abstract }}</p>
	  	  </details>
	  	{% endif %}
      </div>
    {% endfor %}
  
  {% endfor %}
  
  <!-- WORKS IN PROGRESS -->
  <div class="jumbotron text-center">
    <h2>Works in progress</h2>
  </div>
  <div class="card-body">
    {% for item in site.data.publications-wip %}
      "{{ item.title }}"{% if item.coauthors and item.coauthors != "" %} (with {{ item.coauthors }}){% endif %}<br>
      {% unless forloop.last %}<br>{% endunless %}
    {% endfor %}
  </div>
  
  
  <!-- EXTERNAL GRANTS -->
  <div class="jumbotron text-center">
    <h2>External grants</h2>
  </div>
  
  {% for item in site.data.publications-grants %}
    <div class="card-block">
	<b>{{ item.title }}</b> <br>
    {{ item.role }}, with {{ item.coauthors }} <br>
	
	{% if item.details and item.details != "" %}
      {{ item.details }} <br> 
      {{ item.amount }} <br>
      {% if forloop.last == false %} <br> {% endif %}
    {% else %}
      {{ item.amount }} <br>
      <table style="padding:0px; border-collapse: collapse">
      {% for g in item.other %}
        <tr style="border-style:hidden">
        <td style="text-indent:25px">{{ g.entity }}, </td>
        {% if g.number and g.number != "" %} <td align="left">{{ g.number }},</td>{% endif %}
        <td align="left">{{ g.date }},</td>
        <td align="left">{{ g.amount }}</td>
        </tr>
      {% endfor %}
      </table>		
	{% endif %}
    </div>
  {% endfor %}
  
</div>



