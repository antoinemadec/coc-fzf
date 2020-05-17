" description: list of yanks provided by coc-yank

let s:prompt = 'Coc Yanks> '
let s:yank_file_path = $HOME . '/.config/coc/extensions/coc-yank-data/yank'

function! coc_fzf#yanks#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let l:raw_yanks = readfile(s:yank_file_path)
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

  return reverse(l:yanks)
endfunction

function! s:yank_handler(cmd) abort
  let l:content = a:cmd[0]
  let @" = l:content
  execute 'put "'
endfunction
