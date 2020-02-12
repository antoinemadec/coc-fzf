let s:prompt = 'Coc Symbols> '

function! coc_fzf#symbols#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
  let command_fmt = g:coc_fzf_plugin_dir . '/script/get_workspace_symbols.py %s %s %s %s'
  let channel = coc#client#get_channel(coc#client#get_client('coc'))
  let initial_command = printf(command_fmt, v:servername, channel, bufnr(), "''")
  let reload_command = printf(command_fmt, v:servername, channel, bufnr(), '{q}')
  let l:opts = {
        \ 'source': initial_command,
        \ 'sink*': function('s:symbol_handler'),
        \ 'options': ['--multi','--expect='.expect_keys, '--bind', 'change:reload:'.reload_command,
        \ '--phony', '--layout=reverse-list', '--ansi', '--prompt=' . s:prompt],
        \ }
  call fzf#run(fzf#wrap(l:opts))
  call s:syntax()
endfunction

let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'}

function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  let l:Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, default)
  return l:Cmd
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_SymbolsHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_SymbolsSymbol /\v^>\?\s*\S\+/ contained containedin=CocFzf_SymbolsHeader
    syntax match CocFzf_SymbolsType /\v\s\[.*\]/ contained containedin=CocFzf_SymbolsHeader
    syntax match CocFzf_SymbolsFile /\s\S*\s\d\+,\d\+$/ contained containedin=CocFzf_SymbolsHeader
    syntax match CocFzf_SymbolsLine /\s\d\+/ contained containedin=CocFzf_SymbolsFile
    syntax match CocFzf_SymbolsColumn /,\d\+$/ contained containedin=CocFzf_SymbolsFile
    highlight default link CocFzf_SymbolsSymbol Normal
    highlight default link CocFzf_SymbolsType Typedef
    highlight default link CocFzf_SymbolsFile Comment
    highlight default link CocFzf_SymbolsLine Ignore
    highlight default link CocFzf_SymbolsColumn Ignore
  endif
endfunction

function! s:symbol_handler(sym) abort
  let cmd = s:action_for(a:sym[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    if stridx('edit', cmd) < 0
      execute 'silent' cmd
    endif
  endif
  let l:parsed = s:parse_symbol(a:sym[1:])
  if type(l:parsed) == v:t_dict
    execute 'buffer' bufnr(l:parsed["filename"], 1)
    call cursor(l:parsed["lnum"], l:parsed["col"])
    normal! zz
  endif
endfunction

function! s:parse_symbol(sym) abort
  let l:match = matchlist(a:sym, '^\(.*\) \[\([^[]*\)\] \(.*\) \(\d\+\),\(\d\+\)')[1:5]
  if empty(l:match) || empty(l:match[0])
    return
  endif
  return ({'text': l:match[0], 'kind': l:match[1], 'filename': l:match[2], 'lnum': l:match[3], 'col': l:match[4]})
endfunction
