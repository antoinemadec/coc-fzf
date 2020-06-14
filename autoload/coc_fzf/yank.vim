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
  call s:syntax()
endfunction

let s:yank_type_names = {
  \ 'V': 'line',
  \ 'v': 'char',
  \ '^v': 'block'}

function! s:add_formatted_yank(yanks, yank_parts, yank_type) abort
  let l:yank = join(a:yank_parts, "\n")
  let l:yank = a:yank_type . '  ' . l:yank
  call add(a:yanks, l:yank)
endfunction

function! s:get_yanks(raw_yanks) abort
  let l:yanks = []
  let l:yank_parts = []
  let l:index = 0

  for l:line in a:raw_yanks
    if l:line =~ '^\t'
      call add(l:yank_parts, l:line[1:])
    else
      if len(l:yank_parts) != 0
        " we are at the end of a yank, push it into the list
        call s:add_formatted_yank(l:yanks, l:yank_parts, l:yank_type)
        let l:yank_parts = []
      endif

      " we are starting the next yank, get metadata
      let l:metadata = split(l:line, '|')
      let l:yank_type = s:yank_type_names[metadata[4]]
    endif
  endfor

  " make sure our list empty; if not, add it to the list
  if len(l:yank_parts) != 0
    call s:add_formatted_yank(l:yanks, l:yank_parts, l:yank_type)
  endif

  return reverse(yanks)
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_YankHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_YankType /\v^\s*(line|char|block)/ contained containedin=CocFzf_YankHeader
    highlight default link CocFzf_YankType Typedef
  endif
endfunction

function! s:parse_yanks(yanks) abort
  let l:parsed_list = []

  for str in a:yanks
    let match = matchlist(str, '^\s*\(char\|line\|block\)  \(.*\)$')
    echom match
    let l:parsed_list += [match[2]]
  endfor

  return l:parsed_list
endfunction

function! s:yank_handler(cmd) abort
  let l:parsed_yanks = s:parse_yanks(a:cmd)
  let content = join(l:parsed_yanks, "\n")

  if &cb == 'unnamedplus'
    let @+ = content
  elseif &cb == 'unnamed'
    let @* = content
  else
    let @" = content
  endif
  put
endfunction
