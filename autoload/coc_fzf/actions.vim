" description: code actions of selected range

let s:prompt = 'Coc Actions> '

function! coc_fzf#actions#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let g:coc_fzf_actions = CocAction('codeActions')
  if !empty(g:coc_fzf_actions)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_actions(),
          \ 'sink*': function('s:action_handler'),
          \ 'options': ['--multi', '--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call coc_fzf#common#set_syntax(function('s:syntax'))
    call fzf#run(fzf#wrap(opts))
  else
    call coc_fzf#common#echom_info('actions list is empty')
  endif
endfunction

function! s:format_coc_action(item) abort
  " title [clientId] (kind)
  let str = a:item.title . ' [' . a:item.clientId . ']'
  if exists('a:item.kind')
    let str .=  ' (' . a:item.kind . ')'
  endif
  return str
endfunction

function! s:get_actions() abort
  let entries = map(copy(g:coc_fzf_actions), 's:format_coc_action(v:val)')
  let index = 0
  while index < len(entries)
     let entries[index] .= ' ' . index
     let index = index + 1
  endwhile
  return entries
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_ActionHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_ActionKind /([^)]\+)/ contained containedin=CocFzf_ActionHeader
    syntax match CocFzf_ActionId /\[[^\]]\+\]/ contained containedin=CocFzf_ActionHeader
    syntax match CocFzf_ActionTitle /^>\?\s*[^\[]\+/ contained  containedin=CocFzf_ActionHeader
    syntax match CocFzf_ActionIndex /\d\+$/ contained containedin=CocFzf_ActionHeader
    highlight default link CocFzf_ActionIndex Ignore
    highlight default link CocFzf_ActionTitle Normal
    highlight default link CocFzf_ActionId Type
    highlight default link CocFzf_ActionKind Comment
  endif
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
