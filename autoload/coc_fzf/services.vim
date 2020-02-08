let s:prompt = 'Coc Services> '

function! coc_fzf#services#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let l:first_call = a:0 ? a:1 : 1
  let l:serv = CocAction('services')
  if !empty(l:serv)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let l:opts = {
          \ 'source': s:get_services(l:serv),
          \ 'sink*': function('s:service_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--layout=reverse-list', '--ansi', '--prompt=' . s:prompt],
          \ }
    call fzf#run(fzf#wrap(l:opts))
    call s:syntax()
    if (!l:first_call)
      call feedkeys('i')
      call coc_fzf#common#fzf_selector_restore()
    endif
  endif
endfunction

function! s:format_coc_service(item) abort
  " state id [state] languages
  let l:state = ' '
  if a:item.state == 'running'
    let l:state = '*'
  endif
  let l:languages = join(a:item.languageIds, ', ')
  return l:state . ' ' . a:item.id . ' [' . a:item.state . '] '. l:languages
endfunction

function! s:get_services(serv) abort
  return map(a:serv, 's:format_coc_service(v:val)')
endfunction

let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  let l:Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, default)
  return l:Cmd
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_ExtensionHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_ServiceStar /\v^\>?\s+\*/ contained containedin=CocFzf_ExtensionHeader
    syntax match CocFzf_ServiceName /\v%4c[^[]*(\[)@=/ contained containedin=CocFzf_ExtensionHeader
    syntax match CocFzf_ServiceState /\v\[[^[\]]*\]/ contained containedin=CocFzf_ExtensionHeader
    syntax match CocFzf_ServiceLanguages /\v(\])@<=.*$/ contained containedin=CocFzf_ExtensionHeader
    highlight default link CocFzf_ServiceStar Special
    highlight default link CocFzf_ServiceName Type
    highlight default link CocFzf_ServiceState Statement
    highlight default link CocFzf_ServiceLanguages Comment
  endif
endfunction

function! s:service_handler(ext) abort
  let l:parsed = s:parse_service(a:ext[1:])
  if type(l:parsed) == v:t_dict
    silent call CocAction('toggleService', l:parsed.id)
    call coc_fzf#services#fzf_run(0)
  endif
endfunction

function! s:parse_service(ext) abort
  let l:match = matchlist(a:ext, '^\(\*\?\)\s*\(\S*\)\s\[\(\S*\)\]\s\(\S*\)')[1:4]
  if empty(l:match) || empty(l:match[1])
    return
  endif
  return ({'state' : l:match[2], 'id' : l:match[1], 'languages' : l:match[3]})
endfunction
