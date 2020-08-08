" description: registered commands of coc.nvim

let s:prompt = 'Coc Commands> '

function! coc_fzf#commands#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let cmds = CocAction('commands')
  if !empty(cmds)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_commands(cmds),
          \ 'sink*': function('s:command_handler'),
          \ 'options': ['--multi', '--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(opts))
  else
    call coc_fzf#common#echom_info('commands list is empty')
  endif
endfunction

function! s:format_coc_command(item) abort
  return a:item.id . ' ' .
        \ coc_fzf#common_fzf_vim#green(a:item.title, 'Comment')
endfunction

function! s:get_commands(cmds) abort
  return map(a:cmds, 's:format_coc_command(v:val)')
endfunction

function! s:command_handler(cmd) abort
  if empty(a:cmd)
    return
  endif
  let cmd = coc_fzf#common#get_action_from_key(a:cmd[0])
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
