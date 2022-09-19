function s:check_fzf_vim() abort
  call health#report_start('fzf.vim (optional)')
  let got_fzf_vim = 1
  try
    call fzf#vim#with_preview()
  catch
    let got_fzf_vim = 0
  endtry
  if got_fzf_vim
    call health#report_ok('fzf.vim found')
  else
    call health#report_warn("fzf.vim not found. 'location' won't work, previews won't be available",
          \ ['Install the following vim plugin', "  Plug 'junegunn/fzf.vim'"])
  endif
endfunction

function! health#coc_fzf#check() abort
  call s:check_fzf_vim()
endfunction
