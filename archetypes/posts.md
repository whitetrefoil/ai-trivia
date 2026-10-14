---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: {{ .Date }}
provider: ""  # 原对话中回答的 AI 的提供方，不是整理本文的 AI
model: ""     # 原对话中回答的 AI 的模型 ID，不是整理本文的 AI
---

{{"{{"}}< me >}}
我的问题
{{"{{"}}< /me >}}

{{"{{"}}< ai >}}
AI 的回答
{{"{{"}}< /ai >}}
