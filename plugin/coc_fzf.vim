" coc-fzf - use FZF for CocList sources
" Maintainer:   Antoine Madec <aja.madec@gmail.com>
" Version:      0.1

if exists('g:loaded_coc_fzf')
  finish
else
  let g:loaded_coc_fzf = 'yes'
endif

command CocFzfListDiagnostics  call coc_fzf#diagnostics#fzf_run(0)
command BCocFzfListDiagnostics call coc_fzf#diagnostics#fzf_run(1)
