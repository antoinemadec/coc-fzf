let s:prompt = 'Coc Outline> '

function! coc_fzf#outline#fzf_run() abort
  let expect_keys = join(keys(get(g:, 'fzf_action', s:default_action)), ',')
  let l:opts = {
        \ 'source': s:get_outline(),
        \ 'sink*': function('s:symbol_handler'),
        \ 'options': ['--multi','--expect='.expect_keys,
        \ '--layout=reverse-list', '--ansi', '--prompt=' . s:prompt],
        \ }
  call fzf#run(fzf#wrap(l:opts))
  call s:syntax()
endfunction

function! s:format_coc_diagnostic(item) abort
  if len(a:item) >= 4
    let l:parts = split(a:item, "\t")
    let l:sym = parts[0]
    let l:line = substitute(parts[2], ';".*$', '', '')
    let l:type = '[' . parts[3] . ']'
    return l:sym . " " . l:type . " " . l:line
  else
    return ''
  endif
endfunction

function! s:get_outline() abort
  " ctags: try force language to filtetype
  let l:shell_cmd = "ctags -f - --excmd=number --language-force=" . &ft . " " . expand("%")
  let l:symbols = systemlist(shell_cmd)
  if (!(len(l:symbols) && v:shell_error == 0))
    " ctags: try without forcing language
    let l:shell_cmd = "ctags -f - --excmd=number " . expand("%")
    let l:symbols = systemlist(shell_cmd)
  endif
  return v:shell_error == 0 ? map(l:symbols, 's:format_coc_diagnostic(v:val)'):[]
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
    exec 'syntax match CocFzf_DiagnosticHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_DiagnosticSymbol /\v^>\?\s*\S\+/ contained containedin=CocFzf_DiagnosticHeader
    syntax match CocFzf_DiagnosticType /\v\s\[.*\]\s/ contained containedin=CocFzf_DiagnosticHeader
    syntax match CocFzf_DiagnosticLine /\d\+$/ contained containedin=CocFzf_DiagnosticHeader
    highlight default link CocFzf_DiagnosticSymbol Normal
    highlight default link CocFzf_DiagnosticType String
    highlight default link CocFzf_DiagnosticLine Comment
  endif
endfunction

function! s:symbol_handler(sym) abort
  normal! m'
  let cmd = s:action_for(a:sym[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
  endif
  let l:line_nb = s:parse_symbol(a:sym[1:])
  execute l:line_nb
  normal! ^zvzz
endfunction

function! s:parse_symbol(sym) abort
  let l:fields = split(a:sym[0])
  return len(l:fields) >= 2 ? l:fields[2] : ''
endfunction
