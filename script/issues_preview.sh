#!/usr/bin/env bash

tmp_dir="$1"
str="$2"

index=${str/* /}
filename="$tmp_dir/${index}.md"

# bad markdown support
unsupported_themes=",1337,GitHub,Sublime Snazzy,zenburn,"

if command -v bat > /dev/null; then
  if [ "$BAT_THEME" != "" ] && [[ "$unsupported_themes" =~ ",$BAT_THEME," ]]; then
    export BAT_THEME=""
  fi
  bat_cmd="bat --style="${BAT_STYLE:-numbers}" --color=always --pager=never"
  $bat_cmd $filename 2> /dev/null
else
  cat $filename 2> /dev/null
fi
