" coc-fzf - use FZF for CocList sources
" Maintainer:   Antoine Madec <aja.madec@gmail.com>
" Version:      0.1

if exists('g:loaded_coc_fzf')
  finish
else
  let g:loaded_coc_fzf = 'yes'
endif

if !exists("g:coc_fzf_preview_toggle_key")
    let g:coc_fzf_preview_toggle_key = '?'
endif
if !exists("g:coc_fzf_preview")
    let g:coc_fzf_preview = 'up:50%'
endif
if !exists("g:coc_fzf_preview_fullscreen")
    let g:coc_fzf_preview_fullscreen = 0
endif
if !exists("g:coc_fzf_opts")
    let g:coc_fzf_opts = ['--layout=reverse-list']
endif
if !exists("g:coc_fzf_location_delay")
  let g:coc_fzf_location_delay = 0
endif

let g:coc_fzf_plugin_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:coc_fzf_plugin_dir = fnamemodify(g:coc_fzf_plugin_dir, ':h')

command! -range -nargs=* -complete=custom,coc_fzf#common#list_options CocFzfList call coc_fzf#lists#fzf_run(<range>, <f-args>)
command CocFzfListResume call coc_fzf#common#call_last_logged_function()
