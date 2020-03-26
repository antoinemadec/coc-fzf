#!/usr/bin/env bash

description=1
[ "$1" = "--no-description" ] && description=0

coc_fzf_source_dir="$(dirname $0)/../autoload/coc_fzf"
for f in $(ls "$coc_fzf_source_dir"); do
  src="${f/%.vim/}"
  [ "$src" = "common" ] && continue
  [ "$src" = "common_fzf_vim" ] && continue
  [ "$src" = "lists" ] && continue
  printf "$src"
  if [ "$description" = 1 ]; then
    grep '" description: ' $coc_fzf_source_dir/$src.vim | sed "s/.*: \(.*\)/ \1/"
  else
    printf "\n"
  fi
done
