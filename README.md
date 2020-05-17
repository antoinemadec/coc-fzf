fzf :heart: coc.nvim
===============

Use [fzf][fzf] instead of [coc.nvim][coc.nvim] built-in fuzzy finder.

![](https://raw.githubusercontent.com/antoinemadec/gif/master/coc_fzf.gif)

Rationale
---------

**❗coc-fzf only supports nvim❗**, PR are welcome if you want to change this.

Inspired by [Robert Buhren's functions][RobertBuhren] and [coc-denite][coc_denite] this plugin aims to use [fzf][fzf] for CocList sources when possible.
The goal is to keep the [coc.nvim][coc.nvim] style and leverage your [FZF Vim integration][fzf_vim_integration], such as layout, shortcuts, options etc.

Installation
---------

Make sure to have the following plugins in your **vimrc**:
```vim
Plug 'coc.nvim',
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf'
```

Commands
---------

| Command                                   | List                                                                             |
| ---                                       | ---                                                                              |
| `:CocFzfList        `                     | Equivalent to :CocList                                                           |
| `:CocFzfList actions`                     | Equivalent to :CocList actions                                                   |
| `:CocFzfList commands`                    | Equivalent to :CocList commands                                                  |
| `:CocFzfList diagnostics`                 | Equivalent to :CocList diagnostics. Toggle preview: '?'                          |
| `:CocFzfList diagnostics --current-buf`   | Equivalent to :CocList diagnostics in the current buffer only                    |
| `:CocFzfList extensions`                  | Equivalent to :CocList extensions                                                |
| `:CocFzfList location`                    | Equivalent to :CocList location. Toggle preview: '?'. Requires [fzf.vim][fzfvim] |
| `:CocFzfList outline`                     | Equivalent to :CocList outline, with colors. Requires [ctags][ctags]             |
| `:CocFzfList symbols`                     | Equivalent to :CocList symbols                                                   |
| `:CocFzfList symbols --kind {kind}`       | Equivalent to :CocList symbols -kind {kind}                                      |
| `:CocFzfList services`                    | Equivalent to :CocList services                                                  |
| `:CocFzfList yanks`                       | Equivalent to :CocList yanks. Requires [coc-yank][coc-yank]                      |
| `:CocFzfListResume`                       | Equivalent to :CocListResume                                                     |

Options
---------

| Option                         | Type   | Description                                                    | Default value               |
| ---                            | ---    | ---                                                            | ---                         |
| `g:coc_fzf_preview_toggle_key` | string | Change the key to toggle the preview window                    | `'?'`                       |
| `g:coc_fzf_preview`            | string | Change the preview window position                             | `'up:50%'`                  |
| `g:coc_fzf_opts`               | array  | Pass additional parameters to fzf, e.g. `['--layout=reverse']` | `['--layout=reverse-list']` |

Vimrc Example
---------
```vim
nnoremap <silent> <space>a  :<C-u>CocFzfList diagnostics<CR>
nnoremap <silent> <space>b  :<C-u>CocFzfList diagnostics --current-buf<CR>
nnoremap <silent> <space>c  :<C-u>CocFzfList commands<CR>
nnoremap <silent> <space>e  :<C-u>CocFzfList extensions<CR>
nnoremap <silent> <space>l  :<C-u>CocFzfList location<CR>
nnoremap <silent> <space>o  :<C-u>CocFzfList outline<CR>
nnoremap <silent> <space>s  :<C-u>CocFzfList symbols<CR>
nnoremap <silent> <space>S  :<C-u>CocFzfList services<CR>
nnoremap <silent> <space>p  :<C-u>CocFzfListResume<CR>
```

FAQ
---------

**Q**: How to get the FZF floating window?
**A**: You can look at [FZF Vim integration][fzf_vim_integration]:
```vim
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
```

License
-------

MIT

[fzf_vim_integration]: https://github.com/junegunn/fzf/blob/master/README-VIM.md
[fzf]:                 https://github.com/junegunn/fzf
[coc.nvim]:            https://github.com/neoclide/coc.nvim
[RobertBuhren]:        https://gist.github.com/RobertBuhren/02e05506255c667c0038ce74ee1cef96
[coc_denite]:          https://github.com/neoclide/coc-denite
[ctags]:               https://github.com/universal-ctags/ctags
[fzfvim]:              https://github.com/junegunn/fzf.vim
[coc-yank]:            https://github.com/neoclide/coc-yank
