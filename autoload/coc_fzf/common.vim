function coc_fzf#common#coc_has_extension(ext) abort
  return index(CocAction('loadedExtensions'), a:ext) != -1
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

" list_sources['name'] = {
"   'description': 'string',
"   'wrapper':     'command' or v:null,
"   'deleted':     0
" }
let s:list_sources = {}

function coc_fzf#common#get_list_sources() abort
  let s:list_sources = extend(
        \ map(CocAction('listDescriptions'),
        \ '{"description": v:val, "wrapper": v:null, "deleted": 0}'),
        \ s:list_sources)
  " add 'actions' despite its removal from the original CocList
  let s:list_sources = extend({'actions':
        \ {'description': 'code actions of file and line or selected region',
        \ 'wrapper': v:null, 'deleted': 0}}, s:list_sources)
  let all_sources = keys(s:list_sources)
  let original_sources = []
  for src in all_sources
    if filereadable(printf('%s/autoload/coc_fzf/%s.vim', g:coc_fzf_plugin_dir, src))
      let original_sources += [src]
    endif
  endfor
  let wrapper_sources = filter(copy(all_sources), 'index(original_sources, v:val)==-1')
  for src in wrapper_sources
    if s:list_sources[src].wrapper == v:null
      let s:list_sources[src].wrapper = 'CocList ' . src
    endif
  endfor
  return filter(copy(s:list_sources), 'v:val.deleted == 0')
endfunction

function coc_fzf#common#add_list_source(name, description, wrapper) abort
  let s:list_sources[a:name] = {
        \ "description": a:description,
        \ "wrapper": a:wrapper,
        \ "deleted": 0}
endfunction

function coc_fzf#common#delete_list_source(name) abort
  let s:list_sources[a:name].deleted = 1
endfunction

let coc_fzf#common#kinds = sort(
      \ ['File', 'Module', 'Namespace', 'Package', 'Class', 'Method',
      \ 'Property', 'Field', 'Constructor', 'Enum', 'Interface', 'Function',
      \ 'Variable', 'Constant', 'String', 'Number', 'Boolean', 'Array',
      \ 'Object', 'Key', 'Null', 'EnumMember', 'Struct', 'Event', 'Operator',
      \ 'TypeParameter'])

function coc_fzf#common#list_options(ArgLead, CmdLine, CursorPos) abort
  let coc_fzf_list_opts = ['--original-only']
  let diagnostics_opts = ['--current-buf']
  let symbols_opts = ['--kind']
  let args_list = split(a:CmdLine)[1:]
  " CocFzfList options
  if len(args_list) && args_list[0][0] == '-'
    if args_list[0] == '--original-only'
      return ''
    else
      return join(coc_fzf_list_opts, "\n")
    endif
  endif
  " source options
  let source = len(args_list) >= 1 ? args_list[0] : ''
  if source == 'diagnostics'
    return join(diagnostics_opts, "\n")
  elseif source == 'symbols' || source == 'outline'
    if index(args_list[-2:-1], '--kind') >= 0
      return join(g:coc_fzf#common#kinds, "\n")
    endif
    return join(symbols_opts, "\n")
  endif
  let list_sources = sort(keys(coc_fzf#common#get_list_sources()))
  if index(list_sources, source) < 0
    return join(coc_fzf_list_opts + list_sources, "\n")
  endif
  return ''
endfunction

function coc_fzf#common#echom_error(msg, ...) abort
  let delay = a:0 ? a:1 : 10
  call s:echo_core(a:msg, 'Error', delay, 'echom')
endfunction

function coc_fzf#common#echom_info(msg, ...) abort
  let delay = a:0 ? a:1 : 10
  call s:echo_core(a:msg, 'MoreMsg', delay, 'echom')
endfunction

function coc_fzf#common#echo_progress_start(msg) abort
  let g:coc_fzf_echo_progress = {
    \ 'msg': a:msg,
    \ 'frames': ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'],
    \ 'index': 0,
    \ 'timer': timer_start(100, function('s:echo_progress_cb'), {'repeat': -1})
    \ }
endfunction

function coc_fzf#common#echo_progress_stop() abort
  call timer_stop(g:coc_fzf_echo_progress.timer)
endfunction

function s:echo_progress_cb(timer)
  let d = g:coc_fzf_echo_progress
  let msg = d.msg . ' ' . d.frames[d.index]
  call s:echo_core(msg, 'MoreMsg', 0, 'echo')
  let d.index = (d.index+1) % len(d.frames)
endfunction

let s:echo_cmd_queue = []

function s:echo_cb(timer) abort
  if len(s:echo_cmd_queue)
    exe s:echo_cmd_queue[0]
    call remove(s:echo_cmd_queue, 0)
  endif
endfunction

function s:echo_core(msg, highlight, delay, cmd)
  let cmd = "echohl " .  a:highlight . " | " . a:cmd . " '[coc-fzf] " . a:msg .
        \ "' | echohl None"
  if a:delay == 0
    exe cmd
  else
    let s:echo_cmd_queue += [cmd]
    let timer = timer_start(a:delay, function('s:echo_cb'))
  endif
endfunction

function s:with_preview(placeholder, custom_cmd, wrap) abort
  let wrapped_opts = {}
  let placeholder_opt = {}
  let preview_window_pos_size = g:coc_fzf_preview
  let preview_window_scroll_offset = '+{2}-5'

  if g:coc_fzf_preview_available
    if empty(preview_window_pos_size)
      let preview_window_pos_size = get(g:, 'fzf_preview_window', &columns >= 120 ? 'right': '')
      if empty(preview_window_pos_size)
        return {}
      endif
    endif
    if !empty(a:placeholder)
      let placeholder_opt = {'placeholder': a:placeholder}
      let scroll = split(a:placeholder, ':')[1]
      let preview_window_scroll_offset = '+' . scroll . '-5'
    endif
    let preview_window_opt = preview_window_pos_size
    if a:wrap
      let preview_window_opt .= ":wrap"
    endif
    if empty(a:custom_cmd)
      let preview_window_opt .= ':' . preview_window_scroll_offset
    endif
    let wrapped_opts = fzf#vim#with_preview(
          \ placeholder_opt, preview_window_opt, g:coc_fzf_preview_toggle_key)
    let wrapped_opts.options += ['--delimiter=:']
    if !empty(a:custom_cmd)
      let preview_command_index = index(wrapped_opts.options, '--preview') + 1
      let wrapped_opts.options[preview_command_index] = a:custom_cmd
    endif
  endif

  return wrapped_opts
endfunction

function coc_fzf#common#fzf_run_with_preview(opts, ...) abort
  let preview_placeholder = a:0 >= 1 ? a:1 : ""
  let preview_custom_cmd = a:0 >= 2 ? a:2 : ""
  let preview_wrap = a:0 >= 3 ? a:3 : 0
  let extra = s:with_preview(preview_placeholder, preview_custom_cmd, preview_wrap)
  let eopts  = has_key(extra, 'options') ? remove(extra, 'options') : ''
  let merged = extend(copy(a:opts), extra)
  call coc_fzf#common_fzf_vim#merge_opts(merged, eopts)
  call fzf#run(fzf#wrap(merged, g:coc_fzf_preview_fullscreen))
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

  normal! m'
  if !empty(cmd)
    execute 'silent' cmd first["filename"]
  else
    execute 'buffer' bufnr(first["filename"], 1)
    set buflisted
  endif
  if type(first) == v:t_dict
    call cursor(first["lnum"], first["col"])
    mark '
    normal! zz
  endif

  if len(a:parsed_dict_list) > 1
    call setqflist(a:parsed_dict_list)
    copen
    wincmd p
  endif

endfunction
