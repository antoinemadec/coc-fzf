let s:prompt = 'Coc Lists> '

function! coc_fzf#lists#fzf_run(...) abort
  if a:0
    " execute one source/list
    let l:src = a:000[0]
    let l:src_opts = a:000[1:]
    if index(g:coc_fzf#common#sources_list, l:src) < 0
      call coc_fzf#common#echom_error('List ' . l:src . ' does not exist')
      return
    endif
    call call('coc_fzf#' . l:src . '#fzf_run', l:src_opts)
  else
    " prompt all available lists
    call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let ext_command = g:coc_fzf_plugin_dir . '/script/get_lists.sh'
    echom ext_command
    let l:opts = {
          \ 'source': ext_command,
          \ 'sink*': function('s:list_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(l:opts))
    call s:syntax()
  endif
endfunction

let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'}

function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  let l:Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, default)
  return l:Cmd
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_ListsHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_ListsDescription /\s.*$/ contained containedin=CocFzf_ListsHeader
    syntax match CocFzf_ListsList /^>\?\s*\S\+/ contained containedin=CocFzf_ListsHeader
    highlight default link CocFzf_ListsList Normal
    highlight default link CocFzf_ListsDescription Comment
  endif
endfunction

function! s:list_handler(list) abort
  let cmd = s:action_for(a:list[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    if stridx('edit', cmd) < 0
      execute 'silent' cmd
    endif
  endif
  let l:src = split(a:list[1])[0]
  if !empty(l:src)
    execute 'call coc_fzf#' . l:src . '#fzf_run()'
    if &ft == 'fzf'
      call feedkeys('i')
    endif
  endif
endfunction
