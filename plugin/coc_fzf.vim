" coc-fzf - use FZF for CocList sources
" Maintainer:   Antoine Madec <aja.madec@gmail.com>
" Version:      0.1

if exists('g:loaded_coc_fzf')
  finish
else
  let g:loaded_coc_fzf = 'yes'
endif

command CocFzfListDiagnostics call CocFzfListDiagnostics()
command BCocFzfListDiagnostics call CocFzfListDiagnostics(1)

function! s:format_coc_diagnostic(item) abort
  return (has_key(a:item,'file')  ? bufname(a:item.file) : '')
        \ . '|' . (a:item.lnum  ? a:item.lnum : '')
        \ . (a:item.col ? ' col ' . a:item.col : '')
        \ . '| ' . a:item.severity
        \ . ' ' . a:item.message
endfunction

function! s:get_current_diagnostics(current_buffer_only) abort
  if a:current_buffer_only
    let l:diags = filter(copy(CocAction('diagnosticList')), {key, val -> val.file ==# expand('%:p')})
  else
    let l:diags = filter(copy(CocAction('diagnosticList')), 1)
  endif
  return map(l:diags, 's:format_coc_diagnostic(v:val)')
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

function! CocFzfListDiagnostics(...) abort
  let l:current_buffer_only = a:0 ? a:1 : 0
  let l:diags = CocAction('diagnosticList')
  if !empty(l:diags)
    let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
    let l:opts = {
          \ 'source': s:get_current_diagnostics(l:current_buffer_only),
          \ 'sink*': function('s:error_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--layout=reverse-list', '--ansi', '--prompt=Coc Diagnostics> '],
          \ }
    call fzf#run(fzf#wrap(l:opts))
    call s:syntax()
  endif
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    syntax match CocFzfDiagnosticHeader /\v^.*$/
    syntax match CocFzfDiagnosticFile '^[^|]*' nextgroup=CocFzfQuickFixSeparator
    syntax match CocFzfQuickFixSeparator '|' nextgroup=CocFzfQuickFixLineNumber contained
    syntax match CocFzfQuickFixLineNumber '[^|]*' contained
    syntax match CocFzfDiagnosticError /\sError\s/
    syntax match CocFzfDiagnosticWarning /\sWarning\s/
    syntax match CocFzfDiagnosticInfo /\sInformation\s/
    syntax match CocFzfDiagnosticHint /\sHint\s/
    highlight default link CocFzfDiagnosticFile Comment
    highlight default link CocFzfQuickFixLineNumber Comment
    highlight default link CocFzfDiagnosticError CocErrorSign
    highlight default link CocFzfDiagnosticWarning CocWarningSign
    highlight default link CocFzfDiagnosticInfo CocInfoSign
    highlight default link CocFzfDiagnosticHint CocHintSign
  endif
endfunction

function! s:error_handler(err) abort
  normal! m'
  let cmd = s:action_for(a:err[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
  endif
  let l:parsed = s:parse_error(a:err[1:])
  execute 'buffer' bufnr(l:parsed["bufnr"])
  call cursor(l:parsed["linenr"], l:parsed["colnr"])
  normal! ^zvzz
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
