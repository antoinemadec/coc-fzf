" description: registered completion sources

let s:prompt = 'Coc Sources> '

function! coc_fzf#sources#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let sources = CocAction('sourceStat')
  if !empty(sources)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_sources(sources),
          \ 'sink*': function('s:source_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(opts))
  else
    call coc_fzf#common#echom_info('sources list is empty')
  endif
endfunction

function! s:format_coc_source(item) abort
  " name [shortcut] triggerCharacters priority filetypes
  let state = ' '
  if a:item.disabled == v:false
    let state = '*'
  endif
  let trigger_chars = join(a:item.triggerCharacters, '')
  let file_types = join(a:item.filetypes, ',')
  let shortcut = '['. a:item.shortcut .']'
  return printf('%s %-40s %-40s %-40s %25s %s',
        \ coc_fzf#common_fzf_vim#red(state, 'Special'),
        \ coc_fzf#common_fzf_vim#yellow(a:item.name, 'Type'),
        \ coc_fzf#common_fzf_vim#red(shortcut, 'Statement'),
        \ coc_fzf#common_fzf_vim#cyan(trigger_chars, 'Normal'),
        \ coc_fzf#common_fzf_vim#magenta(a:item.priority, 'Number'),
        \ coc_fzf#common_fzf_vim#green(file_types, 'Comment'))
endfunction

function! s:get_sources(sources) abort
  return map(a:sources, 's:format_coc_source(v:val)')
endfunction

function! s:source_handler(ext) abort
  if empty(a:ext)
    return
  endif
  let parsed = s:parse_source(a:ext[1:])
  if type(parsed) == v:t_dict
    silent call CocAction("toggleSource", parsed.name)
    call coc_fzf#sources#fzf_run()
  endif
endfunction

function! s:parse_source(ext) abort
  let match = matchlist(a:ext, '^\(.\)\s*\(\S*\)\s*.*')[1:2]
  if empty(match) || empty(l:match[1])
    return
  endif
  return ({'state' : match[0], 'name' : l:match[1]})
endfunction
