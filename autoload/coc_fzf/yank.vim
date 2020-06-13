" description: list of yanks provided by coc-yank

let s:prompt = 'Coc Yank> '
let s:yank_relative_file_path = '/coc-yank-data/yank'

function! coc_fzf#yank#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  if !coc_fzf#common#coc_has_extension('coc-yank')
    call coc_fzf#common#echom_error("coc-yank is not installed")
    return
  endif
  let yank_file_path = coc#util#extension_root() . s:yank_relative_file_path
  try
    let raw_yanks = readfile(l:yank_file_path)
  catch
    call coc_fzf#common#echom_info("yank file cannot be found")
    return
  endtry
  let opts = {
        \ 'source': s:get_yanks(raw_yanks),
        \ 'sink*': function('s:yank_handler'),
        \ 'options': ['--multi', '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts
        \ }
  call fzf#run(fzf#wrap(opts))
endfunction

function! s:get_yanks(raw_yanks) abort
  let yanks = []
  let yank_parts = []

  for line in a:raw_yanks
    if line =~ '^\t'
      call add(yank_parts, l:line[1:])
    elseif len(yank_parts) != 0
      let yank = join(yank_parts, "\n")
      call add(yanks, l:yank)
      let yank_parts = []
    endif
  endfor

  " make sure our list empty; if not, add it to the list
  if len(yank_parts) != 0
    let yank = join(yank_parts, "\n")
    call add(yanks, l:yank)
  endif

  return reverse(yanks)
endfunction

function! s:yank_handler(cmd) abort
  let content = a:cmd[0]
  if &cb == "unnamedplus"
    let @+ = content
  elseif &cb == "unnamed"
    let @* = content
  else
    let @" = content
  endif
  put
endfunction
