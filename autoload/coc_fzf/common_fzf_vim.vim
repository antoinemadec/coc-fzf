" functions copied from fzf-vim

let s:TYPE = {'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}

function! coc_fzf#common_fzf_vim#merge_opts(dict, eopts)
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

function! s:get_color(attr, ...)
  let gui = has('termguicolors') && &termguicolors
  let fam = gui ? 'gui' : 'cterm'
  let pat = gui ? '^#[a-f0-9]\+' : '^[0-9]\+$'
  for group in a:000
    let code = synIDattr(synIDtrans(hlID(group)), a:attr, fam)
    if code =~? pat
      return code
    endif
  endfor
  return ''
endfunction

let s:ansi = {'black': 30, 'red': 31, 'green': 32, 'yellow': 33, 'blue': 34, 'magenta': 35, 'cyan': 36}

function! s:csi(color, fg)
  let prefix = a:fg ? '38;' : '48;'
  if a:color[0] == '#'
    return prefix.'2;'.join(map([a:color[1:2], a:color[3:4], a:color[5:6]], 'str2nr(v:val, 16)'), ';')
  endif
  return prefix.'5;'.a:color
endfunction

function! s:ansi(str, group, default, ...)
  let fg = s:get_color('fg', a:group)
  let bg = s:get_color('bg', a:group)
  let color = (empty(fg) ? s:ansi[a:default] : s:csi(fg, 1)) .
        \ (empty(bg) ? '' : ';'.s:csi(bg, 0))
  return printf("\x1b[%s%sm%s\x1b[m", color, a:0 ? ';1' : '', a:str)
endfunction

for s:color_name in keys(s:ansi)
  execute "function! coc_fzf#common_fzf_vim#".s:color_name."(str, ...)\n"
        \ "  return s:ansi(a:str, get(a:, 1, ''), '".s:color_name."')\n"
        \ "endfunction"
endfor
