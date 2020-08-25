" description: snippets list

let s:prompt = 'Coc Snippets> '

function! coc_fzf#snippets#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  if !coc_fzf#common#coc_has_extension('coc-snippets')
    call coc_fzf#common#echom_error("coc-snippets is not installed")
    return
  endif
  let snippets = CocAction('listLoadItems', 'snippets')
  if !empty(snippets)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_snippets(snippets),
          \ 'sink*': function('s:line_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call coc_fzf#common#fzf_run_with_preview(opts, '{-3}:{-2}')
  else
    call coc_fzf#common#echom_info('snippets list is empty')
  endif
endfunction

function! s:format_coc_snippet(item) abort
  let pd_split = split(a:item.filterText)
  let prefix = pd_split[0]
  let description = join(pd_split[1:])
  let filename = substitute(a:item.location.uri, 'file://', '', '')
  let filename = substitute(filename, $HOME, '~', '')
  let start = a:item.location.range.start
  let lnum = start.line + 1
  let col = start.character
  let uri_str = coc_fzf#common_fzf_vim#black(':', 'Ignore') .
        \ coc_fzf#common_fzf_vim#green(filename, 'Comment') .
        \ coc_fzf#common_fzf_vim#black(':' . lnum . ':' . col, 'Ignore')
  return printf("%-40s %s%s",
        \ coc_fzf#common_fzf_vim#blue(prefix, 'Identifier'),
        \ description, uri_str)
endfunction

function! s:get_snippets(snippets) abort
  return map(a:snippets, 's:format_coc_snippet(v:val)')
endfunction

function! s:line_handler(lines) abort
  if empty(a:lines)
    return
  endif
  let parsed_dict_list = s:parse_lines(a:lines[1:])
  call coc_fzf#common#process_file_action(a:lines[0], parsed_dict_list)
endfunction

function! s:parse_lines(lines) abort
  let parsed_dict_list = []
  for str in a:lines
    let parsed_dict = {}
    let match = matchlist(str, '\(.*\):\(.*\):\(.*\):\(.*\)')[1:4]
    if empty(match)
      return
    endif
    let parsed_dict['filename'] = expand(match[1])
    let parsed_dict['lnum'] = match[2]
    let parsed_dict['col'] = match[3]
    let parsed_dict['text'] = match[0]
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
