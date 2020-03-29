" coc-fzf - use FZF for CocList sources
" Maintainer:   Antoine Madec <aja.madec@gmail.com>
" Version:      0.1

if exists('g:loaded_coc_fzf')
  finish
else
  let g:loaded_coc_fzf = 'yes'
endif

if !has('nvim')
  " coc-fzf only supports nvim, PR are welcome if you want to change this
  finish
endif

if !exists("g:coc_fzf_preview_toggle_key")
    let g:coc_fzf_preview_toggle_key = '?'
endif
if !exists("g:coc_fzf_preview")
    let g:coc_fzf_preview = 'up:50%'
endif
if !exists("g:coc_fzf_opts")
    let g:coc_fzf_opts = ['--layout=reverse-list']
endif

let g:coc_fzf_plugin_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:coc_fzf_plugin_dir = fnamemodify(g:coc_fzf_plugin_dir, ':h')

if has('nvim')
  augroup CocFzfSelector
    autocmd!
    autocmd TermEnter  * if &ft == 'fzf' | call coc_fzf#common#remap_enter() | endif
    autocmd TermLeave  * if &ft == 'fzf' | call coc_fzf#common#unmap_enter() | endif
  augroup END
endif

command! -nargs=* -complete=custom,coc_fzf#common#list_options CocFzfList call coc_fzf#lists#fzf_run(<f-args>)
command CocFzfListResume call coc_fzf#common#call_last_logged_function()
