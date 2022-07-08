---
layout: Post
title: Now
nowPage: true
permalink: /now
---

{{ site.categories.now[0].content }}

## Previous Now Pages
{% for post in site.categories.now offset: 1 %}
[{{post.title}}]({{post.url}})
{% endfor %}
