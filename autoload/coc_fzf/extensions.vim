let s:prompt = 'Coc Extensions> '

function! coc_fzf#extensions#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let l:first_call = a:0 ? a:1 : 1
  let l:exts = CocAction('extensionStats')
  if !empty(l:exts)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let l:opts = {
          \ 'source': s:get_extensions(l:exts),
          \ 'sink*': function('s:extension_handler'),
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

function! s:format_coc_extension(item) abort
  " state id version root
  let l:state = '+'
  if a:item.state == 'activated'
    let l:state = '*'
  elseif a:item.state == 'disabled'
    let l:state = '-'
  endif
  return l:state . ' ' . a:item.id . ' ' . a:item.root
endfunction

function! s:get_extensions(exts) abort
  let l:exts_activated = filter(copy(a:exts), {key, val -> val.state == 'activated'})
  let l:exts_loaded = filter(copy(a:exts), {key, val -> val.state == 'loaded'})
  let l:exts_disabled = filter(copy(a:exts), {key, val -> val.state == 'disabled'})
  let l:exts = extend(l:exts_activated, l:exts_loaded)
  let l:exts = extend(l:exts, l:exts_disabled)
  return map(l:exts, 's:format_coc_extension(v:val)')
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
    syntax match CocFzf_ExtensionRoot /\v\s*\f+$/ contained containedin=CocFzf_ExtensionHeader
    syntax match CocFzf_ExtensionActivited /\v^\>?\s+\*/ contained containedin=CocFzf_ExtensionHeader
    syntax match CocFzf_ExtensionLoaded /\v^\>?\s+\+\s/ contained containedin=CocFzf_ExtensionHeader
    syntax match CocFzf_ExtensionDisabled /\v^\>?\s+-\s/ contained containedin=CocFzf_ExtensionHeader
    syntax match CocFzf_ExtensionName /\v%5c\S+/ contained containedin=CocFzf_ExtensionHeader
    highlight default link CocFzf_ExtensionRoot Comment
    highlight default link CocFzf_ExtensionDisabled Comment
    highlight default link CocFzf_ExtensionActivited MoreMsg
    highlight default link CocFzf_ExtensionLoaded Normal
    highlight default link CocFzf_ExtensionName String
  endif
endfunction

function! s:extension_handler(ext) abort
  let l:parsed = s:parse_extension(a:ext[1:])
  if type(l:parsed) == v:t_dict
    if l:parsed.state == '*'
      silent call CocAction('deactivateExtension', l:parsed.id)
    elseif l:parsed.state == '+'
      silent call CocAction('activeExtension', l:parsed.id)
    endif
    call coc_fzf#extensions#fzf_run(0)
  endif
endfunction

function! s:parse_extension(ext) abort
  let l:match = matchlist(a:ext, '\v^(.)\s(\S*)\s(.*)')[1:4]
  if empty(l:match) || empty(l:match[0])
    return
  endif
  return ({'state' : l:match[0], 'id' : l:match[1], 'root' : l:match[2]})
endfunction
