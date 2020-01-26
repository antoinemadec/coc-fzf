function! s:format_coc_diagnostic(item) abort
  return (has_key(a:item,'file')  ? bufname(a:item.file) : '')
        \ . '|' . (a:item.lnum  ? a:item.lnum : '')
        \ . (a:item.col ? ' col ' . a:item.col : '')
        \ . '| ' . a:item.severity
        \ . ': ' . a:item.message 
endfunction

function! s:get_current_diagnostics() abort
  " Remove entries not belonging to the current file.
  let l:diags = filter(copy(CocAction('diagnosticList')), {key, val -> val.file ==# expand('%:p')})
  return map(l:diags, 's:format_coc_diagnostic(v:val)')
endfunction

function! s:format_qf_diags(item) abort
  let l:parsed = s:parse_error(a:item)
  return {'bufnr' : bufnr(l:parsed['bufnr']), 'lnum' : l:parsed['linenr'], 'col': l:parsed['colnr'], 'text' : l:parsed['text']}
endfunction

function! s:build_quickfix_list(lines)
  call setqflist(map(a:lines, 's:format_qf_diags(v:val)'),'r', "Diagnostics")
endfunc

let s:TYPE = {'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}

let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  if a:key == 'ctrl-q'
    let l:Cmd = function('s:build_quickfix_list')
  else
    let l:Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, default)
  endif
  return l:Cmd
endfunction

function! GetFzfDiags() abort
  let l:diags = CocAction('diagnosticList')
  if !empty(l:diags)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let l:opts = {
          \ 'source': s:get_current_diagnostics(),
          \ 'sink*': function('s:error_handler'),
          \ 'options': ['--multi','--expect=ctrl-q,'.expect_keys,'--ansi', '--prompt=Coc Diagnostics> '],
          \ }
    call fzf#run(fzf#wrap(l:opts))
    call s:syntax()
  endif
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax match FzfQuickFixFileName '^[^|]*' nextgroup=FzfQuickFixSeparator
    syntax match FzfQuickFixSeparator '|' nextgroup=FzfQuickFixLineNumber contained
    syntax match FzfQuickFixLineNumber '[^|]*' contained contains=FzfQuickFixError
    syntax match FzfQuickFixError 'error' contained

    highlight default link FzfQuickFixFileName Directory
    highlight default link FzfQuickFixLineNumber LineNr
    highlight default link FzfQuickFixError Error
  endif
endfunction

function! s:error_handler(err) abort
   
  let l:Cmd = s:action_for(a:err[0])

  if !empty(l:Cmd) && type(l:Cmd) == s:TYPE.string && stridx('edit', l:Cmd) < 0
    execute 'silent' l:Cmd
  elseif !empty(l:Cmd) && type(l:Cmd) == s:TYPE.funcref
    call l:Cmd(a:err[1:])
    return
  endif
  let l:parsed = s:parse_error(a:err[1:])
  execute 'buffer' bufnr(l:parsed["bufnr"])
  mark '
  call cursor(l:parsed["linenr"], l:parsed["colnr"])
  normal! zvzz

endfunction

function! s:parse_error(err) abort
  let l:match = matchlist(a:err, '\v^([^|]*)\|(\d+)?%(\scol\s(\d+))?.*\|(.*)')[1:4]
  if empty(l:match) || empty(l:match[0])
    return
  endif

  if empty(l:match[1]) && (bufnr(l:match[0]) == bufnr('%'))
    return
  endif

  let l:line_number = empty(l:match[1]) ? 1 : str2nr(l:match[1])
  let l:col_number = empty(l:match[2]) ? 1 : str2nr(l:match[2])
  let l:error_msg = l:match[3]

  return ({'bufnr' : l:match[0],'linenr' : l:line_number, 'colnr':l:col_number, 'text': l:error_msg})
endfunction
