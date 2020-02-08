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
          \ '--layout=reverse-list', '--ansi', '--prompt=' . s:prompt]
          \ }
    let extra = fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:50%', '?')
    let eopts  = has_key(extra, 'options') ? remove(extra, 'options') : ''
    let merged = extend(copy(l:opts), extra)
    call s:merge_opts(merged, eopts)
    call fzf#run(fzf#wrap(merged))
    call s:syntax()
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
    syntax region CocFzf_JumplocationRegion start="^" end="[│┌└]" keepend contains=CocFzf_JumplocationHeader
    syntax match CocFzf_JumplocationFile /^>\?\s*[^:│┌└]\+/ contained containedin=CocFzf_JumplocationHeader
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


"--------------------------------------------------------------
" from fzf-vim
"--------------------------------------------------------------
let s:TYPE = {'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}

function! s:merge_opts(dict, eopts)
  return s:extend_opts(a:dict, a:eopts, 0)
endfunction

function! s:extend_opts(dict, eopts, prepend)
  if empty(a:eopts)
    return
  endif
  if has_key(a:dict, 'options')
    if type(a:dict.options) == s:TYPE.list && type(a:eopts) == s:TYPE.list
      if a:prepend
        let a:dict.options = extend(copy(a:eopts), a:dict.options)
      else
        call extend(a:dict.options, a:eopts)
      endif
    else
      let all_opts = a:prepend ? [a:eopts, a:dict.options] : [a:dict.options, a:eopts]
      let a:dict.options = join(map(all_opts, 'type(v:val) == s:TYPE.list ? join(map(copy(v:val), "fzf#shellescape(v:val)")) : v:val'))
    endif
  else
    let a:dict.options = a:eopts
  endif
endfunction
