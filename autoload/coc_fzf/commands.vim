" description: registered commands of coc.nvim

let s:prompt = 'Coc Commands> '

function! coc_fzf#commands#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let cmds = CocAction('commands')
  if !empty(cmds)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let opts = {
          \ 'source': s:get_commands(cmds),
          \ 'sink*': function('s:command_handler'),
          \ 'options': ['--multi', '--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(opts))
    call s:syntax()
  else
    call coc_fzf#common#echom_info('commands list is empty')
  endif
endfunction

function! s:format_coc_command(item) abort
  return a:item.id . ' ' . a:item.title
endfunction

function! s:get_commands(cmds) abort
  return map(a:cmds, 's:format_coc_command(v:val)')
endfunction

let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  let Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, default)
  return Cmd
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_CommandHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_CommandTitle /\s.*$/ contained containedin=CocFzf_CommandHeader
    syntax match CocFzf_CommandId /^>\?\s*\S\+/ contained  containedin=CocFzf_CommandHeader
    highlight default link CocFzf_CommandTitle Comment
  endif
endfunction

function! s:command_handler(cmd) abort
  let cmd = s:action_for(a:cmd[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
  endif
  let parsed = s:parse_command(a:cmd[1:])
  if type(parsed) == v:t_dict
    call CocActionAsync('runCommand', parsed.id)
  endif
endfunction

function! s:parse_command(cmd) abort
  let match = matchlist(a:cmd, '^\(\S\+\)\s\?\(.*\)$')[1:2]
  if empty(match)
    return
  endif
  return ({'id' : match[0], 'title' : l:match[1]})
endfunction
