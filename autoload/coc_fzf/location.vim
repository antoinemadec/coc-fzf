" description: show locations saved by g:coc_jump_locations variable

let s:prompt = 'Coc Location> '

function! coc_fzf#location#fzf_run() abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  " deepcopy() avoids g:coc_jump_locations corruption
  let l:locs = deepcopy(get(g:, 'coc_jump_locations', ''))
  if !empty(l:locs)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let l:opts = {
          \ 'source': s:get_location(l:locs),
          \ 'sink*': function('s:location_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call coc_fzf#common#fzf_run_with_preview(l:opts)
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
  let l:parsed_dict_list = s:parse_location(a:loc[1:])
  call coc_fzf#common#process_file_action(a:loc[0], l:parsed_dict_list)
endfunction

function! s:parse_location(loc) abort
  let parsed_dict_list = []
  for str in a:loc
    let parsed_dict = {}
    let l:match = matchlist(str, '^\(\S\+\):\(\d\+\):\(\d\+\):\(.*\)')[1:4]
    if empty(l:match) || empty(l:match[0])
      return
    endif
    let parsed_dict['filename'] = l:match[0]
    let parsed_dict['lnum'] = l:match[1]
    let parsed_dict['col'] = l:match[2]
    let parsed_dict['text'] = l:match[3]
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
