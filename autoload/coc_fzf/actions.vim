" description: code actions of selected range

let s:prompt = 'Coc Actions> '

" Pass zero to run for the global buffer and current line, non-zero to run
" according to visualmode()
function! coc_fzf#actions#fzf_run(range) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  if a:range != 0
    " If the user has specified a range, respect that
    let g:coc_fzf_actions = CocAction('codeActions', visualmode())
  else
    " Get the global actions as well as actions for the current line which are
    " not already in the global actions.
    let global_actions = CocAction('codeActions')
    let line_actions = filter(CocAction('codeActions', 'n'), 'index(global_actions, v:val)==-1')
    let g:coc_fzf_actions = map(line_actions, "extend(v:val, {'provenance': 'line'})")
                        \ + map(global_actions, "extend(v:val, {'provenance': 'global'})")
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
  let str = a:item.title .
        \ coc_fzf#common_fzf_vim#yellow(' [' . a:item.clientId . ']', 'Type')
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
  let cmd = coc_fzf#common#get_action_from_key(a:act[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
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
