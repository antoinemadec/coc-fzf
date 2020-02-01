function! coc_fzf#common#remap_enter() abort
  let l:enter_map = maparg('<CR>', 't')
  if l:enter_map != ""
    let s:enter_map = l:enter_map
    tunmap <CR>
  endif
  tnoremap <silent> <CR> <C-\><C-n>:call coc_fzf#common#fzf_selector_save()<CR>i<CR>
endfunction

function! coc_fzf#common#unmap_enter() abort
  tunmap <CR>
  if exists('s:enter_map')
    exe 'tnoremap <silent><expr> <CR> ' . s:enter_map
  endif
endfunction

function! coc_fzf#common#fzf_selector_save() abort
  let l:cmd = 'g/^>/#'
  let t:fzf_selector_line_nb = split(s:redir_exec(l:cmd))[0]
endfunction

function! coc_fzf#common#fzf_selector_restore() abort
  " TODO: normal gg
  let l:c = 1
  while c < t:fzf_selector_line_nb
    call feedkeys("\<Down>")
    let l:c += 1
  endwhile
endfunction

function! s:redir_exec(command) abort
    redir =>output
    silent exec a:command
    redir END
    return output
endfunction
