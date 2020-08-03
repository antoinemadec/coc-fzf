" description: diagnostics of current workspace

let s:prompt = 'Coc Diagnostics> '

function! coc_fzf#diagnostics#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let current_buffer_only = index(a:000, '--current-buf') >= 0
  let diags = CocAction('diagnosticList')
  if !empty(diags)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_diagnostics(diags, l:current_buffer_only),
          \ 'sink*': function('s:error_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call coc_fzf#common#set_syntax(function('s:syntax'))
    call coc_fzf#common#fzf_run_with_preview(opts)
  else
    call coc_fzf#common#echom_info('diagnostics list is empty')
  endif
endfunction

function! s:format_coc_diagnostic(item) abort
  if has_key(a:item, 'file')
    let file = substitute(a:item.file, getcwd() . "/" , "", "")
    let msg = substitute(a:item.message, "\n", " ", "g")
    return file
          \ . ':' . a:item.lnum . ':' . a:item.col . ' '
          \ . a:item.severity . ' ' . msg
  endif
  return ''
endfunction

function! s:get_diagnostics(diags, current_buffer_only) abort
  if a:current_buffer_only
    let diags = filter(a:diags, {key, val -> val.file ==# expand('%:p')})
  else
    let diags = a:diags
  endif
  return map(diags, 's:format_coc_diagnostic(v:val)')
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_DiagnosticHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_DiagnosticFile /^>\?\s*\S\+/ contained containedin=CocFzf_DiagnosticHeader
    syntax match CocFzf_DiagnosticError /\sError\s/ contained containedin=CocFzf_DiagnosticHeader
    syntax match CocFzf_DiagnosticWarning /\sWarning\s/ contained containedin=CocFzf_DiagnosticHeader
    syntax match CocFzf_DiagnosticInfo /\sInformation\s/ contained containedin=CocFzf_DiagnosticHeader
    syntax match CocFzf_DiagnosticHint /\sHint\s/ contained containedin=CocFzf_DiagnosticHeader
    highlight default link CocFzf_DiagnosticFile Comment
    highlight default link CocFzf_DiagnosticError CocErrorSign
    highlight default link CocFzf_DiagnosticWarning CocWarningSign
    highlight default link CocFzf_DiagnosticInfo CocInfoSign
    highlight default link CocFzf_DiagnosticHint CocHintSign
  endif
endfunction

function! s:error_handler(err) abort
  if empty(a:err)
    return
  endif
  let parsed_dict_list = s:parse_error(a:err[1:])
  call coc_fzf#common#process_file_action(a:err[0], parsed_dict_list)
endfunction

function! s:parse_error(err) abort
  let parsed_dict_list = []
  for str in a:err
    let parsed_dict = {}
    let match = matchlist(str, '\v^([^:]*):(\d+):(\d+)(.*)')[1:4]
    if empty(match) || empty(l:match[0])
      return
    endif
    if empty(match[1]) && (bufnr(l:match[0]) == bufnr('%'))
      return
    endif
    let parsed_dict['filename'] = match[0]
    let parsed_dict['lnum'] = empty(match[1]) ? 1 : str2nr(l:match[1])
    let parsed_dict['col'] = empty(match[2]) ? 1 : str2nr(l:match[2])
    let parsed_dict['text'] = match[3]
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
