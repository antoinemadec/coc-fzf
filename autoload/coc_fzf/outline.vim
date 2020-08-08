" description: symbols of current document

let s:prompt = 'Coc Outline> '

function! coc_fzf#outline#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let expect_keys = coc_fzf#common#get_default_file_expect_keys()
  let opts = {
        \ 'source': s:get_outline(),
        \ 'sink*': function('s:symbol_handler'),
        \ 'options': ['--multi','--expect='.expect_keys,
        \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
        \ }
  call fzf#run(fzf#wrap(opts))
endfunction

function! s:format_coc_outline_ctags(item) abort
  if len(a:item) >= 4
    let parts = split(a:item, "\t")
    let sym = parts[0]
    let line = substitute(parts[2], ';".*$', '', '')
    let type = '[' . parts[3] . ']'
    call cursor(line, 0)
    let [l, l:col] = searchpos('\V'.l:sym, 'nc', l:line)
    return sym . " " .
          \ coc_fzf#common_fzf_vim#yellow(l:type, 'Typedef') . " " .
          \ coc_fzf#common_fzf_vim#green(l:line, 'Comment') .
          \ coc_fzf#common_fzf_vim#black(',' . l:col, 'Ignore')
  else
    return ''
  endif
endfunction

function! s:format_coc_outline_docsym(item) abort
  let msg = a:item.text .
        \ coc_fzf#common_fzf_vim#yellow(' [' . a:item.kind . '] ', 'Typedef') .
        \ coc_fzf#common_fzf_vim#green(a:item.lnum, 'Comment') .
        \ coc_fzf#common_fzf_vim#black(',' . a:item.col, 'Ignore')
  let indent = ''
  let c = 0
  while c < a:item.level
    let indent .= '  '
    let c += 1
  endwhile
  return indent . l:msg
endfunction

function! s:get_outline() abort
  let symbols = CocAction('documentSymbols')
  if type(symbols) != v:t_list
    " ctags: try force language to filtetype
    let ctags_base_cmd = 'set -o pipefail && ctags -f - --excmd=number'
    let shell_cmd = l:ctags_base_cmd . " --language-force=" . &ft . ' '  . expand("%")
          \ . ' | sort -n --key=3'
    let symbols = systemlist(shell_cmd)
    if (!(len(symbols) && v:shell_error == 0))
      " ctags: try without forcing language
      let shell_cmd = l:ctags_base_cmd . ' '  . expand("%") . ' | sort -n --key=3'
      let symbols = systemlist(shell_cmd)
    endif
    let cur_pos = getpos('.')
    let return_list = v:shell_error == 0 ? map(l:symbols, 's:format_coc_outline_ctags(v:val)'):[]
    call cursor(cur_pos[1:2])
    return return_list
  else
    return map(symbols, 's:format_coc_outline_docsym(v:val)')
  endif
endfunction

function! s:symbol_handler(sym) abort
  if empty(a:sym)
    return
  endif
  let parsed_dict_list = s:parse_symbol(a:sym[1:])
  call coc_fzf#common#process_file_action(a:sym[0], parsed_dict_list)
endfunction

function! s:parse_symbol(sym) abort
  let parsed_dict_list = []
  for str in a:sym
    let parsed_dict = {}
    let match = matchlist(str, '^\s*\(.* \[[^[]*\]\) \(\d\+\),\(\d\+\)')[1:3]
    if empty(match) || empty(l:match[0])
      return
    endif
    let parsed_dict['filename'] = expand('%:p')
    let parsed_dict['text'] = match[0]
    let parsed_dict['lnum'] = match[1]
    let parsed_dict['col'] = match[2]
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
