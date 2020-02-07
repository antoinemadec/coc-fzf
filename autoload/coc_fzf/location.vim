let s:prompt = 'Coc Location> '

function! coc_fzf#location#fzf_run() abort
  " deepcopy() avoids g:coc_jump_locations corruption
  let l:locs = deepcopy(get(g:, 'coc_jump_locations', ''))
  if !empty(l:locs)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let l:opts = {
          \ 'source': s:get_location(l:locs),
          \ 'sink*': function('s:location_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--layout=reverse-list', '--ansi', '--prompt=' . s:prompt],
          \ }
    call fzf#run(fzf#wrap(l:opts))
    call s:syntax()
  endif
endfunction

function! s:format_coc_location(item) abort
  " 'filename' |'lnum' col 'col'| 'text'
  let l:cwd = getcwd()
  let l:filename = substitute(a:item.filename, l:cwd . "/", "", "")
  return l:filename . ' |' . a:item.lnum . ' col ' . a:item.col . '| ' . a:item.text
endfunction

function! s:relpath(filename)
    return s
endfunction

function! s:get_location(locs) abort
  let l:locs = a:locs
  return map(l:locs, 's:format_coc_location(v:val)')
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
    exec 'syntax match CocFzf_JumplocationHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_JumplocationFile /^>\?\s*\S\+/ contained containedin=CocFzf_JumplocationHeader
    syntax match CocFzf_JumplocationLineNumber /\s|[^|]*|\s/ contained containedin=CocFzf_JumplocationHeader
    highlight default link CocFzf_JumplocationFile Directory
    highlight default link CocFzf_JumplocationLineNumber LineNr
  endif
endfunction

function! s:location_handler(loc) abort
  let cmd = s:action_for(a:loc[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
  endif
  let l:parsed = s:parse_location(a:loc[1:])
  if type(l:parsed) == v:t_dict
    execute 'buffer' bufnr(l:parsed["filename"], 1)
    call cursor(l:parsed["lnum"], l:parsed["col"])
    normal! zz
  endif
endfunction

function! s:parse_location(loc) abort
  let l:match = matchlist(a:loc, '^\(\S\+\)\s|\(\d\+\) col \(\d\+\)|\s\(.*\)')[1:4]
  if empty(l:match) || empty(l:match[0])
    return
  endif
  return ({'filename': l:match[0], 'lnum': l:match[1], 'col': l:match[2], 'text': l:match[3]})
endfunction
