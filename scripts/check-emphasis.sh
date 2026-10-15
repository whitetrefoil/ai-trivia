#!/bin/sh
# 检查构建结果中失效的加粗 / 斜体（详见 AGENTS.md「加粗与斜体」）。
# 用法：先执行 hugo --gc --minify，再执行 sh scripts/check-emphasis.sh [public 目录]
# 只看 <main> 正文（不看 <head> 里的摘要），忽略 <pre> / <code> 里的内容；发现问题时逐条列出并以退出码 1 结束。
set -eu
dir="${1:-public}"
[ -d "$dir/posts" ] || { echo "找不到 $dir/posts，请先运行 hugo" >&2; exit 2; }

find "$dir/posts" -name index.html -exec perl -CSD -0777 -ne '
  s#^.*?<main>##s; s#</main>.*##s;
  s#<pre\b.*?</pre>##gs;
  s#<code\b.*?</code>##gs;
  my @hits;
  # 残留的 ** 或成对的单个 *（如 *很好。*然后）
  push @hits, $& while /.{0,12}(?:\*\*|(?<![\w*])\*[^\s*<>][^*<>\n]*?\*(?!\*)).{0,12}/g;
  # 紧挨汉字、没有生效的 _斜体_
  push @hits, $& while /.{0,12}(?:(?<=\p{Han})_[^_\s<>]+_|_[^_\s<>]+_(?=\p{Han})).{0,12}/g;
  # 错位配对：<strong> 套 <strong>、<em> 套 <em>
  push @hits, $& while m#.{0,12}<strong>(?:(?!</strong>).)*?<strong>.{0,12}#gs;
  push @hits, $& while m#.{0,12}<em>(?:(?!</em>).)*?<em>.{0,12}#gs;
  my %seen; @hits = grep { !$seen{$_}++ } @hits;
  if (@hits) { print "$ARGV\n"; print "  $_\n" for @hits; $main::bad = 1 }
  END { exit($main::bad ? 1 : 0) }
' {} + || { echo "发现失效的加粗 / 斜体，修正方法见 AGENTS.md「加粗与斜体」" >&2; exit 1; }
echo "加粗 / 斜体检查通过"
