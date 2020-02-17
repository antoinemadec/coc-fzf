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

" test plugin and bin availability
let g:coc_fzf_location_available = 1
try
  call fzf#vim#with_preview()
catch
  let g:coc_fzf_location_available = 0
endtry

let g:coc_fzf_plugin_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:coc_fzf_plugin_dir = fnamemodify(g:coc_fzf_plugin_dir, ':h')

if has('nvim')
  augroup CocFzfSelector
    autocmd!
    autocmd TermEnter  * if &ft == 'fzf' | call coc_fzf#common#remap_enter() | endif
    autocmd TermLeave  * if &ft == 'fzf' | call coc_fzf#common#unmap_enter() | endif
  augroup END
endif
if g:coc_fzf_location_available
  augroup CocFzfLocation
    autocmd!
    let g:coc_enable_locationlist = 0
    autocmd User CocLocationsChange call coc_fzf#location#fzf_run()
  augroup END
endif

command CocFzfListCommands     call coc_fzf#commands#fzf_run()
command CocFzfListDiagnostics  call coc_fzf#diagnostics#fzf_run(0)
command BCocFzfListDiagnostics call coc_fzf#diagnostics#fzf_run(1)
command CocFzfListExtensions   call coc_fzf#extensions#fzf_run()
command CocFzfListOutline      call coc_fzf#outline#fzf_run()
command CocFzfListSymbols      call coc_fzf#symbols#fzf_run()
command CocFzfListServices     call coc_fzf#services#fzf_run()
if g:coc_fzf_location_available
  command CocFzfListLocation   call coc_fzf#location#fzf_run()
endif

command CocFzfListResume       call coc_fzf#common#call_last_logged_function()
