" description: search workspace symbols

let s:prompt = 'Coc Symbols> '

function! coc_fzf#symbols#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)

  if !CocHasProvider('workspaceSymbols')
    call coc_fzf#common#echom_info('Workspace symbols provider not found for current document')
    return
  endif
  if !has('nvim')
    " get_workspace_symbols.py only supports nvim, PR are welcome
    call coc_fzf#common#echom_info('"CocFzfList symbols" only supported with neovim, '.
          \ 'fallback to CocList', 300)
    execute 'CocList symbols'
    return
  endif
  let python3 = get(g:, 'python3_host_prog', 'python3')
  if has('unix')
    let python3 = substitute(python3, '\~', $HOME, "")
  endif
  if !executable(python3)
    call coc_fzf#common#echom_error(string(python3) . ' is not executable.')
    call coc_fzf#common#echom_error('You need to set g:python3_host_prog.')
    return
  endif

  " parse arguments
  let args = copy(a:000)[:-2] " remove range
  "   --kind <kind>
  let ws_symbols_opts = []
  let kind_idx = index(args, '--kind')
  if kind_idx >= 0
    if len(args) < kind_idx+2
      call coc_fzf#common#echom_error('Missing kind argument')
      return
    elseif index(g:coc_fzf#common#kinds, args[kind_idx+1]) < 0
      call coc_fzf#common#echom_error('Kind ' . args[kind_idx+1] . ' does not exist')
      return
    endif
    let ws_symbols_opts += args[l:kind_idx : l:kind_idx+1]
    call remove(args, l:kind_idx, l:kind_idx+1)
  endif
  "   <query>
  let initial_query = ""
  if !empty(args)
    let initial_query = join(args)
  endif

  let expect_keys = coc_fzf#common#get_default_file_expect_keys()

  " pass ansi code to script to avoid using syntax match
  let ansi_typedef = "'" . coc_fzf#common_fzf_vim#yellow('STRING', 'Typedef') . "'"
  let ansi_comment = "'" . coc_fzf#common_fzf_vim#green('STRING',  'Comment') . "'"
  let ansi_ignore  = "'" . coc_fzf#common_fzf_vim#black('STRING',  'Ignore')  . "'"

  let symbol_excludes = '"' . string(coc#util#get_config('list.source.symbols').excludes) . '"'

  let command_fmt = python3 . ' ' . g:coc_fzf_plugin_dir .
        \ '/script/get_workspace_symbols.py %s %s %s %s %s %s %s %s'
  let initial_command = printf(command_fmt,
        \ join(ws_symbols_opts), v:servername, bufnr(), "'" . initial_query . "'",
        \ ansi_typedef, ansi_comment, ansi_ignore, symbol_excludes)
  let reload_command = printf(command_fmt,
        \ join(ws_symbols_opts), v:servername, bufnr(), '{q}',
        \ ansi_typedef, ansi_comment, ansi_ignore, symbol_excludes)
  let opts = {
        \ 'source': initial_command,
        \ 'sink*': function('s:symbol_handler'),
        \ 'options': ['--multi','--expect='.expect_keys, '--bind', 'change:reload:'.reload_command,
        \ '-q', initial_query, '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
        \ }
  call coc_fzf#common#fzf_run_with_preview(opts, '{-3}:{-2}')
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
    let match = matchlist(str, '^\(.* \[[^[]*\]\):\(.*\):\(\d\+\):\(\d\+\)')[1:4]
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
