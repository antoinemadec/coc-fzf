#!/usr/bin/env sh

str="$(echo "$1" | sed "s/^\s*\(line\|char\|block\)\s\s//g")"
yank="${str% *}"
ft="${str##* }"

if command -v bat > /dev/null; then
  bat_cmd="bat --style="${BAT_STYLE:-numbers}" --color=always --pager=never"
  echo "$yank" | $bat_cmd -l $ft 2> /dev/null
  if [ "$?" != 0 ]; then
    echo "$yank" | $bat_cmd 2> /dev/null
  fi
else
  echo "$yank" | cat 2> /dev/null
fi
