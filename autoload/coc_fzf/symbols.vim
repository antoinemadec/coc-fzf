" description: search workspace symbols

let s:prompt = 'Coc Symbols> '

function! coc_fzf#symbols#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let python3 = get(g:, 'python3_host_prog', 'python3')
  if !executable(python3)
    call coc_fzf#common#echom_error(string(python3) . ' is not executable.')
    call coc_fzf#common#echom_error('You need to set g:python3_host_prog.')
    return
  endif

  if !CocHasProvider('workspaceSymbols')
    call coc_fzf#common#echom_info('Workspace symbols provider not found for current document')
    return
  endif
  let ws_symbols_opts = []
  let kind_idx = index(a:000, '--kind')
  if kind_idx >= 0
    if len(a:000) < kind_idx+2
      call coc_fzf#common#echom_error('Missing kind argument')
      return
    elseif index(g:coc_fzf#common#kinds, a:000[kind_idx+1]) < 0
      call coc_fzf#common#echom_error('Kind ' . a:000[kind_idx+1] . ' does not exist')
      return
    endif
    let ws_symbols_opts += a:000[l:kind_idx : l:kind_idx+1]
  endif
  let expect_keys = coc_fzf#common#get_default_file_expect_keys()
  let command_fmt = python3 . ' ' . g:coc_fzf_plugin_dir . '/script/get_workspace_symbols.py %s %s %s %s'
  let initial_command = printf(command_fmt, join(ws_symbols_opts), v:servername, bufnr(), "''")
  let reload_command = printf(command_fmt, join(ws_symbols_opts), v:servername, bufnr(), '{q}')
  let opts = {
        \ 'source': initial_command,
        \ 'sink*': function('s:symbol_handler'),
        \ 'options': ['--multi','--expect='.expect_keys, '--bind', 'change:reload:'.reload_command,
        \ '--phony', '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
        \ }
  call coc_fzf#common#fzf_run_with_preview(opts, {'placeholder': '{-1}'})
  call s:syntax()
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_SymbolsHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_SymbolsSymbol /\v^>\?\s*\S\+/ contained containedin=CocFzf_SymbolsHeader
    syntax match CocFzf_SymbolsType /\v\s\[.*\]/ contained containedin=CocFzf_SymbolsHeader
    syntax match CocFzf_SymbolsFile /\s\S*:\d\+:\d\+$/ contained containedin=CocFzf_SymbolsHeader
    syntax match CocFzf_SymbolsLine /:\d\+/ contained containedin=CocFzf_SymbolsFile
    syntax match CocFzf_SymbolsColumn /:\d\+$/ contained containedin=CocFzf_SymbolsFile
    highlight default link CocFzf_SymbolsSymbol Normal
    highlight default link CocFzf_SymbolsType Typedef
    highlight default link CocFzf_SymbolsFile Comment
    highlight default link CocFzf_SymbolsLine Ignore
    highlight default link CocFzf_SymbolsColumn Ignore
  endif
endfunction

function! s:symbol_handler(sym) abort
  let parsed_dict_list = s:parse_symbol(a:sym[1:])
  call coc_fzf#common#process_file_action(a:sym[0], parsed_dict_list)
endfunction

function! s:parse_symbol(sym) abort
  let parsed_dict_list = []
  for str in a:sym
    let parsed_dict = {}
    let match = matchlist(str, '^\(.* \[[^[]*\]\) \(.*\):\(\d\+\):\(\d\+\)')[1:4]
    if empty(match) || empty(l:match[0])
      return
    endif
    let parsed_dict['text'] = match[0]
    let parsed_dict['filename'] = match[1]
    let parsed_dict['lnum'] = match[2]
    let parsed_dict['col'] = match[3]
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
