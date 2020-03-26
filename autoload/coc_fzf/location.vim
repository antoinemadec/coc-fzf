" description: show locations saved by g:coc_jump_locations variable

let s:prompt = 'Coc Location> '

function! coc_fzf#location#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  " deepcopy() avoids g:coc_jump_locations corruption
  let l:locs = deepcopy(get(g:, 'coc_jump_locations', ''))
  if !empty(l:locs)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let l:opts = {
          \ 'source': s:get_location(l:locs),
          \ 'sink*': function('s:location_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    let extra = fzf#vim#with_preview({'options': '--delimiter : --nth 4..'},
          \ g:coc_fzf_preview, g:coc_fzf_preview_toggle_key)
    let eopts  = has_key(extra, 'options') ? remove(extra, 'options') : ''
    let merged = extend(copy(l:opts), extra)
    call coc_fzf#common_fzf_vim#merge_opts(merged, eopts)
    call fzf#run(fzf#wrap(merged))
    call s:syntax()
  else
    call coc_fzf#common#echom_info('location list is empty')
  endif
endfunction

function! s:format_coc_location(item) abort
  " original is: 'filename' |'lnum' col 'col'| 'text'
  " coc fzf  is: 'filename':'lnum':'col':'text'
  " reason: this format is needed for fzf preview
  let l:cwd = getcwd()
  let l:filename = substitute(a:item.filename, l:cwd . "/", "", "")
  return l:filename . ':' . a:item.lnum . ':' . a:item.col . ':' . a:item.text
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
    syntax region CocFzf_JumplocationRegion start="^" end="[│╭╰]" keepend contains=CocFzf_JumplocationHeader
    syntax match CocFzf_JumplocationFile /^>\?\s*[^:││╭╰]\+/ contained containedin=CocFzf_JumplocationHeader
    syntax match CocFzf_JumplocationLineNumber /:\d\+:\d\+:/ contained containedin=CocFzf_JumplocationHeader
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
  let l:match = matchlist(a:loc, '^\(\S\+\):\(\d\+\):\(\d\+\):\(.*\)')[1:4]
  if empty(l:match) || empty(l:match[0])
    return
  endif
  return ({'filename': l:match[0], 'lnum': l:match[1], 'col': l:match[2], 'text': l:match[3]})
endfunction
