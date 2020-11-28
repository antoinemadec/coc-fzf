" description: list of yanks provided by coc-yank

let s:prompt = 'Coc Yank> '
let s:yank_relative_file_path = '/coc-yank-data/yank'

function! coc_fzf#yank#fzf_run(...) abort
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
        \ 'options': ['--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts
        \ }
  call coc_fzf#common#fzf_run_with_preview(opts, {},
        \ g:coc_fzf_plugin_dir . '/script/yank_preview.sh {}')
endfunction

let s:yank_type_names = {
  \ 'V': 'line',
  \ 'v': 'char',
  \ '^v': 'block'}

function! s:add_formatted_yank(yanks, yank_parts, metadata) abort
  let l:yank_type = s:yank_type_names[a:metadata[4]]
  let filetype = exists("a:metadata[5]") ? a:metadata[5] : "no_ft"

  let l:yank = join(a:yank_parts, '\n')
  let l:yank = coc_fzf#common_fzf_vim#yellow(l:yank_type, 'Typedef') . '  ' . l:yank
  call add(a:yanks, l:yank .
        \ coc_fzf#common_fzf_vim#black(" [ft=" . filetype . "]", 'Ignore'))
endfunction

function! s:get_yanks(raw_yanks) abort
  let l:yanks = []
  let l:yank_parts = []
  let l:index = 0

  for l:line in a:raw_yanks
    if l:line =~ '^\t'
      call add(l:yank_parts, escape(l:line[1:], '\'))
    else
      if len(l:yank_parts) != 0
        " we are at the end of a yank, push it into the list
        call s:add_formatted_yank(l:yanks, l:yank_parts, l:metadata)
        let l:yank_parts = []
      endif

      " we are starting the next yank, get metadata
      let l:metadata = split(l:line, '|')
    endif
  endfor

  " make sure our list empty; if not, add it to the list
  if len(l:yank_parts) != 0
    call s:add_formatted_yank(l:yanks, l:yank_parts, l:metadata)
  endif

  return reverse(yanks)
endfunction

function! s:parse_yanks(yanks) abort
  let str = a:yanks[0]
  let match = matchlist(str, '^\s*\(char\|line\|block\)  \(.*\) .*$')
  let type = match[1][0]
  exe 'let yank_str = printf("' . escape(match[2], '"') .'")'
  return [type, yank_str]
endfunction

function! s:yank_handler(yank) abort
  if empty(a:yank)
    return
  endif
  let [type, yank_str] = s:parse_yanks(a:yank)
  if type == 'l'
    let yank_str .= "\n"
  endif

  if has('nvim')
    call nvim_put(split(yank_str, "\n"), type, 1, 0)
  else
    let y_bak = @y
    let @y = yank_str
    put y
    let @y = y_bak
  endif
endfunction
