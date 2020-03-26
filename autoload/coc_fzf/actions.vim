" description: code actions of selected range

let s:prompt = 'Coc Actions> '

function! coc_fzf#actions#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let g:coc_fzf_actions = CocAction('codeActions')
  if !empty(g:coc_fzf_actions)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let l:opts = {
          \ 'source': s:get_actions(),
          \ 'sink*': function('s:action_handler'),
          \ 'options': ['--multi', '--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(l:opts))
    call s:syntax()
  else
    call coc_fzf#common#echom_info('actions list is empty')
  endif
endfunction

function! s:format_coc_action(item) abort
  " title [clientId] (kind)
  let l:str = a:item.title . ' [' . a:item.clientId . ']'
  if exists('a:item.kind')
    let l:str .=  ' (' . a:item.kind . ')'
  endif
  return l:str
endfunction

function! s:get_actions() abort
  let l:entries = map(copy(g:coc_fzf_actions), 's:format_coc_action(v:val)')
  let index = 0
  while index < len(l:entries)
     let l:entries[index] .= ' ' . index
     let index = index + 1
  endwhile
  return l:entries
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
  let cmd = s:action_for(a:act[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
  endif
  let l:index = s:parse_action(a:act[1:])
  if type(l:index) == v:t_number
    call CocAction('doCodeAction', g:coc_fzf_actions[l:index])
  endif
endfunction

function! s:parse_action(act) abort
  let l:match = matchlist(a:act, '^.* \(\d\+\)$')[1]
  if empty(l:match)
    return
  endif
  return str2nr(l:match)
endfunction
