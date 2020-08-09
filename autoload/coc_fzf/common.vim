function coc_fzf#common#coc_has_extension(ext) abort
  return len(filter(CocAction('extensionStats'), {key, val -> val.id == a:ext}))
endfunction

" [function_name, args_string]
let s:last_func_call = []

function! coc_fzf#common#log_function_call(sfile, args_list) abort
  let func_name = substitute(a:sfile, '.*\(\.\.\|\s\)', '', '')
  let s:last_func_call = [func_name, a:args_list]
endfunction

function! coc_fzf#common#call_last_logged_function() abort
  if !empty(s:last_func_call)
    call call(s:last_func_call[0], s:last_func_call[1])
  endif
endfunction

function! s:redir_exec(command) abort
    redir =>output
    silent exec a:command
    redir END
    return output
endfunction

function coc_fzf#common#get_list_names(...) abort
  let opt = a:0 ? ' ' . a:1 . ' ' : ' '
  return systemlist(g:coc_fzf_plugin_dir . '/script/get_lists.sh' . opt . join(coc#rpc#request('listNames', [])))
endfunction

let coc_fzf#common#kinds = ['File', 'Module', 'Namespace', 'Package', 'Class', 'Method',
      \ 'Property', 'Field', 'Constructor', 'Enum', 'Interface', 'Function',
      \ 'Variable', 'Constant', 'String', 'Number', 'Boolean', 'Array',
      \ 'Object', 'Key', 'Null', 'EnumMember', 'Struct', 'Event', 'Operator',
      \ 'TypeParameter']

function coc_fzf#common#list_options(ArgLead, CmdLine, CursorPos) abort
  let diagnostics_opts = ['--current-buf']
  let symbols_opts = ['--kind']
  let CmdLineList = split(a:CmdLine)
  let source = len(l:CmdLineList) >= 2 ? l:CmdLineList[1] : ''
  if source == 'diagnostics'
    return join(diagnostics_opts, "\n")
  elseif source == 'symbols'
    if index(CmdLineList[-2:-1], '--kind') >= 0
      return join(g:coc_fzf#common#kinds, "\n")
    endif
    return join(symbols_opts, "\n")
  endif
  let sources_list = coc_fzf#common#get_list_names('--no-description')
  if index(sources_list, source) < 0
    return join(sources_list, "\n")
  endif
  return ''
endfunction

function coc_fzf#common#echom_error(msg) abort
  exe "echohl Error | echom '[coc-fzf] " . a:msg . "' | echohl None"
endfunction

function coc_fzf#common#echom_info(msg) abort
  exe "echohl MoreMsg | echom '[coc-fzf] " . a:msg . "' | echohl None"
endfunction

function s:with_preview(opts, custom_cmd) abort
  let wrapped_opts = {}

  if g:coc_fzf_preview_available
    let preview_window = g:coc_fzf_preview
    if empty(preview_window)
      let preview_window = get(g:, 'fzf_preview_window', &columns >= 120 ? 'right': '')
    endif
    if len(preview_window)
      let wrapped_opts = fzf#vim#with_preview(a:opts, preview_window, g:coc_fzf_preview_toggle_key)
      if strlen(a:custom_cmd)
        let preview_command_index = index(wrapped_opts.options, '--preview') + 1
        let wrapped_opts.options[preview_command_index] = a:custom_cmd
      endif
    endif
  endif

  return wrapped_opts
endfunction

function coc_fzf#common#fzf_run_with_preview(opts, ...) abort
  let preview_opts = a:0 >= 1 ? a:1 : {}
  let preview_custom_cmd = a:0 >= 2 ? a:2 : ""
  let extra = s:with_preview(preview_opts, preview_custom_cmd)
  let eopts  = has_key(extra, 'options') ? remove(extra, 'options') : ''
  let merged = extend(copy(a:opts), extra)
  call coc_fzf#common_fzf_vim#merge_opts(merged, eopts)
  call fzf#run(fzf#wrap(merged))
endfunction

let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'}

function coc_fzf#common#get_default_file_expect_keys() abort
  return join(keys(get(g:, 'fzf_action', s:default_action)), ',')
endfunction

function coc_fzf#common#get_action_from_key(key) abort
  return get(get(g:, 'fzf_action', s:default_action), a:key)
endfunction

function coc_fzf#common#process_file_action(key, parsed_dict_list) abort
  if empty(a:parsed_dict_list)
    return
  endif

  let cmd = coc_fzf#common#get_action_from_key(a:key)
  let first = a:parsed_dict_list[0]

  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd first["filename"]
  else
    execute 'buffer' bufnr(first["filename"], 1)
  endif
  if type(first) == v:t_dict
    mark '
    call cursor(first["lnum"], first["col"])
    normal! zz
  endif

  if len(a:parsed_dict_list) > 1
    call setqflist(a:parsed_dict_list)
    copen
    wincmd p
  endif

endfunction
