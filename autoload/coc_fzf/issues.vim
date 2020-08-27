" description: issues on github/gitlab

let s:prompt = 'Coc Issues> '
let s:issues_tmp_dir = g:coc_fzf_plugin_dir . '/tmp/issues'

function! coc_fzf#issues#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  if !coc_fzf#common#coc_has_extension('coc-git')
    call coc_fzf#common#echom_error("coc-git is not installed")
    return
  endif
  let g:coc_fzf_issues = CocAction('listLoadItems', 'issues')
  if !empty(g:coc_fzf_issues)
    call s:write_body_to_file(g:coc_fzf_issues)
    let opts = {
          \ 'source': s:get_issues(g:coc_fzf_issues),
          \ 'sink*': function('s:line_handler'),
          \ 'options': ['--expect=enter',
          \'--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call coc_fzf#common#fzf_run_with_preview(opts, {},
          \ g:coc_fzf_plugin_dir . '/script/issues_preview.sh ' . s:issues_tmp_dir . ' {}',
          \ 1)
  else
    call coc_fzf#common#echom_info('issues list is empty')
  endif
endfunction

function s:write_body_to_file(issues) abort
  call delete(s:issues_tmp_dir, "rf")
  call mkdir(s:issues_tmp_dir, "p")
  let i = 0
  for issue in a:issues
    let filename = printf("%s/%0d.md", s:issues_tmp_dir, i)
    call writefile(split(issue.data.body, "\n"), filename)
    let i += 1
  endfor
endfunction

function! s:format_coc_issue(item) abort
  return a:item.label
endfunction

function! s:get_issues(issues) abort
  let entries = map(copy(a:issues), 's:format_coc_issue(v:val)')
  let index = 0
  while index < len(entries)
     let entries[index] .= ' ' . coc_fzf#common_fzf_vim#black(index, 'Ignore')
     let index = index + 1
  endwhile
  return entries
endfunction

function! s:line_handler(lines) abort
  if empty(a:lines)
    return
  endif
  let url = s:parse_lines(a:lines[1:])
  call coc#util#open_url(url)
endfunction

function! s:parse_lines(lines) abort
  for str in a:lines
    let index = split(str)[-1]
    return g:coc_fzf_issues[index].data.url
  endfor
endfunction
