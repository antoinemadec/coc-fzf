function s:check_ctags() abort
  call health#report_start('ctags (optional)')
  if executable('ctags')
    call health#report_ok('ctag found')
  else
    call health#report_warn("ctags not found, outline won't work if symbols are not supported",
          \ ['git clone https://github.com/universal-ctags/ctags.git',
          \ 'cd ctags',
          \ './autogen.sh',
          \ './configure',
          \ 'make',
          \ 'sudo make install'
          \ ])
  endif
endfunction

function s:check_fzf_vim() abort
  call health#report_start('fzf.vim (optional)')
  let l:got_fzf_vim = 1
  try
    call fzf#vim#with_preview()
  catch
    let l:got_fzf_vim = 0
  endtry
  if l:got_fzf_vim
    call health#report_ok('fzf.vim found')
  else
    call health#report_warn("fzf.vim not found, location won't work",
          \ ['Install the following vim plugin', "  Plug 'junegunn/fzf.vim'"])
  endif
endfunction

function! health#coc_fzf#check() abort
  call s:check_ctags()
  call s:check_fzf_vim()
endfunction
