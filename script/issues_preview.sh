#!/usr/bin/env bash

tmp_dir="$1"
str="$2"

index=${str/* /}
filename="$tmp_dir/${index}.md"

if command -v bat > /dev/null; then
  bat_cmd="bat --style="${BAT_STYLE:-numbers}" --color=always --pager=never"
  $bat_cmd $filename 2> /dev/null
else
  cat $filename 2> /dev/null
fi
