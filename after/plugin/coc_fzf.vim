" test other plugins availability

let g:coc_fzf_preview_available = 1
try
  call fzf#vim#with_preview()
catch
  let g:coc_fzf_preview_available = 0
endtry

if g:coc_fzf_preview_available
  augroup CocFzfLocation
    autocmd!
    let g:coc_enable_locationlist = 0
    if ('nvim')
      autocmd User CocLocationsChange call coc_fzf#location#fzf_run()
    else
      " avoid weird race condition in Vim
      autocmd User CocLocationsChange call timer_start(10, 'CocFzfLocationsVimRun')
      function! CocFzfLocationsVimRun(id)
        call coc_fzf#location#fzf_run()
      endfunction
    endif
  augroup END
endif
