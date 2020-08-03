" description: coc-fzf available list sources

let s:prompt = 'Coc Lists> '

function! coc_fzf#lists#fzf_run(...) abort
  if a:0
    " execute one source/list
    let src = a:000[0]
    let src_opts = a:000[1:]
    let sources_list = coc_fzf#common#get_list_names('--no-description')
    if index(sources_list, src) < 0
      call coc_fzf#common#echom_error('List ' . src . ' does not exist')
      return
    endif
    call call('coc_fzf#' . src . '#fzf_run', l:src_opts)
  else
    " prompt all available lists
    call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': coc_fzf#common#get_list_names(),
          \ 'sink*': function('s:list_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call coc_fzf#common#set_syntax(function('s:syntax'))
    call fzf#run(fzf#wrap(opts))
  endif
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
  if empty(a:list)
    return
  endif
  let cmd = coc_fzf#common#get_action_from_key(a:list[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    if stridx('edit', cmd) < 0
      execute 'silent' cmd
    endif
  endif
  let src = split(a:list[1])[0]
  if !empty(src)
    execute 'call coc_fzf#' . src . '#fzf_run()'
  endif
endfunction
