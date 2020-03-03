#!/usr/bin/env bash

coc_fzf_plugin_dir="$1"
coc_nvim_plugin_dir="$2"

coc_fzf_source_dir="$coc_fzf_plugin_dir/autoload/coc_fzf"
coc_nvim_source_dir="$coc_nvim_plugin_dir/src/list/source"

for f in $(ls $coc_fzf_source_dir); do
  src="${f/%.vim/}"
  [ "$src" = "common" ] && continue
  [ "$src" = "lists" ] && continue
  grep 'description = ' $coc_nvim_source_dir/$src.ts | sed "s/.* '\(.*\)'/$src \1/"
done
