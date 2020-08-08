" description: registered services of coc.nvim

let s:prompt = 'Coc Services> '

function! coc_fzf#services#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let first_call = a:0 ? a:1 : 1
  let serv = CocAction('services')
  if !empty(serv)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_services(serv),
          \ 'sink*': function('s:service_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(opts))
    call coc_fzf#common#remap_enter_to_save_fzf_selector()
    if (!first_call)
      call coc_fzf#common#fzf_selector_restore()
    endif
  else
    call coc_fzf#common#echom_info('services list is empty')
  endif
endfunction

function! s:format_coc_service(item) abort
  " state id [state] languages
  let state = ' '
  if a:item.state == 'running'
    let state = '*'
  endif
  let languages = join(a:item.languageIds, ', ')
  return  coc_fzf#common_fzf_vim#red(state . ' ', 'Special') .
        \ coc_fzf#common_fzf_vim#yellow(a:item.id, 'Type') .
        \ coc_fzf#common_fzf_vim#red(' [' . a:item.state . '] ', 'Statement') .
        \ coc_fzf#common_fzf_vim#black(l:languages, 'Comment')
endfunction

function! s:get_services(serv) abort
  return map(a:serv, 's:format_coc_service(v:val)')
endfunction

function! s:service_handler(ext) abort
  if empty(a:ext)
    return
  endif
  let parsed = s:parse_service(a:ext[1:])
  if type(parsed) == v:t_dict
    silent call CocAction('toggleService', parsed.id)
    call coc_fzf#services#fzf_run(0)
  endif
endfunction

function! s:parse_service(ext) abort
  let match = matchlist(a:ext, '^\(\*\?\)\s*\(\S*\)\s\[\(\S*\)\]\s\(\S*\)')[1:4]
  if empty(match) || empty(l:match[1])
    return
  endif
  return ({'state' : match[2], 'id' : l:match[1], 'languages' : l:match[3]})
endfunction
