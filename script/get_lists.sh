#!/usr/bin/env bash

coc_fzf_source_dir="$(dirname $0)/../autoload/coc_fzf"

for f in $(ls "$coc_fzf_source_dir"); do
  src="${f/%.vim/}"
  [ "$src" = "common" ] && continue
  [ "$src" = "lists" ] && continue
  grep '" description: ' $coc_fzf_source_dir/$src.vim | sed "s/.*: \(.*\)/$src \1/"
done
