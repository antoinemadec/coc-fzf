function s:check_ctags() abort
  call health#report_start('ctags (optional)')
  if executable('ctags')
    call health#report_ok('ctag found')
  else
    call health#report_warn("ctags not found, outline won't work if symbols are not supported",
          \ ['Install universal-ctags via your distributions package manager',
          \ 'See https://github.com/universal-ctags/ctags for compile instructions'])
  endif
endfunction

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
  call s:check_ctags()
  call s:check_fzf_vim()
endfunction
