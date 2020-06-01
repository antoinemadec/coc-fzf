" description: list of yanks provided by coc-yank

let s:prompt = 'Coc Yank> '
let s:yank_relative_file_path = '/coc-yank-data/yank'

function! coc_fzf#yank#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let l:yank_file_path = coc#util#extension_root() . s:yank_relative_file_path
  let l:raw_yanks = readfile(l:yank_file_path)
  let l:opts = {
        \ 'source': s:get_yanks(l:raw_yanks),
        \ 'sink*': function('s:yank_handler'),
        \ 'options': ['--multi', '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts
        \ }
  call fzf#run(fzf#wrap(l:opts))
endfunction

function! s:get_yanks(raw_yanks) abort
  let l:yanks = []
  let l:yank_parts = []

  for l:line in a:raw_yanks
    if l:line =~ '^\t'
      call add(l:yank_parts, l:line[1:])
    elseif len(yank_parts) != 0
      let l:yank = join(yank_parts, "\n")
      call add(l:yanks, l:yank)
      let l:yank_parts = []
    endif
  endfor

  " make sure our list empty; if not, add it to the list
  if len(yank_parts) != 0
    let l:yank = join(yank_parts, "\n")
    call add(l:yanks, l:yank)
  endif

  return reverse(l:yanks)
endfunction

function! s:yank_handler(cmd) abort
  let l:content = a:cmd[0]
  if &cb == "unnamedplus"
    let @+ = l:content
  elseif &cb == "unnamed"
    let @* = l:content
  else
    let @" = l:content
  endif
  put
endfunction
