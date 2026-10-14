---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: {{ .Date }}
provider: ""
model: ""
---

{{"{{"}}< me >}}
我的问题
{{"{{"}}< /me >}}

{{"{{"}}< ai >}}
AI 的回答
{{"{{"}}< /ai >}}
