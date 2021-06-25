" description: code actions of selected range

let s:prompt = 'Coc Actions> '

" pass nothing or range=0 to list codeActions for the file and current line,
" range>0 to run on selected region
function! coc_fzf#actions#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let range = a:0 ? a:1 : 0
  if range != 0
    let g:coc_fzf_actions = map(CocAction('codeActions', visualmode()),
          \ "extend(v:val, {'provenance': 'selected'})")
  else
    let file_actions = CocAction('codeActions')
    let line_actions = filter(CocAction('codeActions', 'line'), 'index(file_actions, v:val)==-1')
    let cursor_actions = filter(CocAction('codeActions', 'cursor'), 'index(file_actions, v:val)==-1')
    let g:coc_fzf_actions =
                        \   map(file_actions, "extend(v:val, {'provenance': 'file'})")
                        \ + map(line_actions, "extend(v:val, {'provenance': 'line'})")
                        \ + map(cursor_actions, "extend(v:val, {'provenance': 'cursor'})")
  endif
  if !empty(g:coc_fzf_actions)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_actions(),
          \ 'sink*': function('s:action_handler'),
          \ 'options': ['--multi', '--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(opts))
  else
    call coc_fzf#common#echom_info('actions list is empty')
  endif
endfunction

function! s:format_coc_action(item) abort
  " title [clientId] (kind)
  let command = get(get(a:item, 'command', {}), 'command', '')
  let index = stridx(l:command, '.')
  let client_id = l:index < 1 ? '' : l:command[:index - 1]
  let str = a:item.title .
        \ (empty(l:client_id) ? '' : coc_fzf#common_fzf_vim#yellow(' [' . l:client_id . ']', 'Type'))
  if exists('a:item.kind')
    let str .=  coc_fzf#common_fzf_vim#green(' (' . a:item.kind . ')', 'Comment')
  endif
  if exists('a:item.provenance')
    let str .=  coc_fzf#common_fzf_vim#green(' [' . a:item.provenance . ']', 'Provenance')
  endif
  return str
endfunction

function! s:get_actions() abort
  let entries = map(copy(g:coc_fzf_actions), 's:format_coc_action(v:val)')
  let index = 0
  while index < len(entries)
     let entries[index] .= ' ' . coc_fzf#common_fzf_vim#black(index, 'Ignore')
     let index = index + 1
  endwhile
  return entries
endfunction

function! s:action_handler(act) abort
  if empty(a:act)
    return
  endif
  let index = s:parse_action(a:act[1:])
  if type(index) == v:t_number
    call CocAction('doCodeAction', g:coc_fzf_actions[index])
  endif
endfunction

function! s:parse_action(act) abort
  let match = matchlist(a:act, '^.* \(\d\+\)$')[1]
  if empty(match)
    return
  endif
  return str2nr(match)
endfunction
