#!/usr/bin/env bash

description=1
if [ "$1" = "--no-description" ]; then
  description=0
  shift 1
fi

available_coc_lists=" $@ "

coc_fzf_source_dir="$(dirname $0)/../autoload/coc_fzf"
for f in $(ls "$coc_fzf_source_dir"); do
  src="${f/%.vim/}"
  [[ "$available_coc_lists" =~ " $src " ]] || continue
  printf "$src"
  if [ "$description" = 1 ]; then
    grep '" description: ' $coc_fzf_source_dir/$src.vim | sed "s/.*: \(.*\)/ \1/"
  else
    printf "\n"
  fi
done
