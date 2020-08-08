" description: manage coc extensions

let s:prompt = 'Coc Extensions> '

function! coc_fzf#extensions#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let first_call = a:0 ? a:1 : 1
  let exts = CocAction('extensionStats')
  if !empty(exts)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_extensions(exts),
          \ 'sink*': function('s:extension_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(opts))
    call coc_fzf#common#remap_enter_to_save_fzf_selector()
    if (!first_call)
      call coc_fzf#common#fzf_selector_restore()
    endif
  else
    call coc_fzf#common#echom_info('extensions list is empty')
  endif
endfunction

function! s:format_coc_extension(item) abort
  " state id version root
  let state = '+'
  if a:item.state == 'activated'
    let state = coc_fzf#common_fzf_vim#yellow('*', 'MoreMsg')
  elseif a:item.state == 'disabled'
    let state = coc_fzf#common_fzf_vim#green('-', 'Comment')
  endif
  let local = a:.item.isLocal ? coc_fzf#common_fzf_vim#green(' [RTP] ', 'MoreMsg') : ' '
  return state . ' ' .
        \ coc_fzf#common_fzf_vim#green(a:item.id, 'String') .
        \ local .
        \ a:item.version . ' ' .
        \ coc_fzf#common_fzf_vim#green(a:item.root, 'Comment')
endfunction

function! s:get_extensions(exts) abort
  let exts_activated = filter(copy(a:exts), {key, val -> val.state == 'activated'})
  let exts_loaded = filter(copy(a:exts), {key, val -> val.state == 'loaded'})
  let exts_disabled = filter(copy(a:exts), {key, val -> val.state == 'disabled'})
  let exts = extend(l:exts_activated, l:exts_loaded)
  let exts = extend(l:exts, l:exts_disabled)
  return map(exts, 's:format_coc_extension(v:val)')
endfunction

function! s:extension_handler(ext) abort
  if empty(a:ext)
    return
  endif
  let parsed = s:parse_extension(a:ext[1:])
  if type(parsed) == v:t_dict
    if parsed.state == '*'
      silent call CocAction('deactivateExtension', parsed.id)
    elseif parsed.state == '+'
      silent call CocAction('activeExtension', parsed.id)
    endif
    call coc_fzf#extensions#fzf_run(0)
  endif
endfunction

function! s:parse_extension(ext) abort
  let match = matchlist(a:ext, '\v^(.)\s(\S*)\s(.*)')[1:4]
  if empty(match) || empty(l:match[0])
    return
  endif
  return ({'state' : match[0], 'id' : l:match[1], 'root' : l:match[2]})
endfunction
