" description: output channels of coc.nvim

let s:prompt = 'Coc Output> '

function! coc_fzf#output#fzf_run(...) abort
  call coc_fzf#common#log_function_call(expand('<sfile>'), a:000)
  let output = CocAction('listLoadItems', 'output')
  if !empty(output)
    let expect_keys = coc_fzf#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_output(output),
          \ 'sink*': function('s:line_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_fzf_opts,
          \ }
    call fzf#run(fzf#wrap(opts))
  else
    call coc_fzf#common#echom_info('output list is empty')
  endif
endfunction

function! s:format_coc_output(item) abort
  return a:item.label
endfunction

function! s:get_output(output) abort
  return map(a:output, 's:format_coc_output(v:val)')
endfunction

function! s:line_handler(lines) abort
  if empty(a:lines)
    return
  endif
  let cmd = coc_fzf#common#get_action_from_key(a:lines[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
  endif
  let parsed_dict_list = s:parse_lines(a:lines[1:])
  for parsed in parsed_dict_list
    call CocActionAsync('runCommand', 'workspace.showOutput', parsed.channel_name)
  endfor
endfunction

function! s:parse_lines(lines) abort
  let parsed_dict_list = []
  for str in a:lines
    let parsed_dict = {}
    let parsed_dict['channel_name'] = str
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
