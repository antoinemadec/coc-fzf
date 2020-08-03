" description: registered completion sources

let s:prompt = 'Coc Sources> '

function! coc_fzf#sources#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let first_call = a:0 ? a:1 : 1
  let sources = CocAction('sourceStat')
  if !empty(sources)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_sources(sources),
          \ 'sink*': function('s:source_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call coc_fzf#common#set_syntax(function('s:syntax'))
    call fzf#run(fzf#wrap(opts))
    call coc_fzf#common#remap_enter_to_save_fzf_selector()
    if (!first_call)
      call coc_fzf#common#fzf_selector_restore()
    endif
  else
    call coc_fzf#common#echom_info('sources list is empty')
  endif
endfunction

function! s:format_coc_source(item) abort
  " name [shortcut] triggerCharacters priority filetypes
  let state = ' '
  if a:item.disabled == v:false
    let state = '*'
  endif
  let trigger_chars = join(a:item.triggerCharacters, '')
  let file_types = join(a:item.filetypes, ',')
  let shortcut = '['. a:item.shortcut .']'
  return printf('%s %-30s %-10s %-10s %-3d %s',
        \ state, a:item.name, shortcut, trigger_chars, a:item.priority, file_types)
endfunction

function! s:get_sources(sources) abort
  return map(a:sources, 's:format_coc_source(v:val)')
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocFzf_SourceHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocFzf_SourceStar /\v^\>?\s+\*/ contained containedin=CocFzf_SourceHeader
    syntax match CocFzf_SourceName /\v%4c[^[]*(\[)@=/ contained containedin=CocFzf_SourceHeader
    syntax match CocFzf_SourceState /\v\[[^ ]*\]/ contained containedin=CocFzf_SourceHeader
    syntax match CocFzf_SourcePriority /\v \d+/ contained containedin=CocFzf_SourceHeader
    syntax match CocFzf_SourceLanguages /\v( \d+ )@<=.*$/ contained containedin=CocFzf_SourceHeader
    highlight default link CocFzf_SourceStar Special
    highlight default link CocFzf_SourceName Type
    highlight default link CocFzf_SourceState Statement
    highlight default link CocFzf_SourcePriority Number
    highlight default link CocFzf_SourceLanguages Comment
  endif
endfunction

function! s:source_handler(ext) abort
  if empty(a:ext)
    return
  endif
  let parsed = s:parse_source(a:ext[1:])
  if type(parsed) == v:t_dict
    silent call CocAction("toggleSource", parsed.name)
    call coc_fzf#sources#fzf_run(0)
  endif
endfunction

function! s:parse_source(ext) abort
  let match = matchlist(a:ext, '^\(.\)\s*\(\S*\)\s*.*')[1:2]
  if empty(match) || empty(l:match[1])
    return
  endif
  return ({'state' : match[0], 'name' : l:match[1]})
endfunction
