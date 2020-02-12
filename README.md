fzf :heart: coc.nvim
===============

Use [fzf][fzf] instead of [coc.nvim][coc.nvim] built-in fuzzy finder.

![](https://raw.githubusercontent.com/antoinemadec/gif/master/coc_fzf.gif)

Rationale
---------

**❗coc-fzf only supports nvim❗**, PR are welcome if you want to change this.

Inspired by [Robert Buhren's functions][RobertBuhren] and [coc-denite][coc_denite] this plugin aims to use [fzf][fzf] for CocList sources when possible.
The goal is to keep the [coc.nvim][coc.nvim] style and leverage your [FZF Vim integration][fzf_vim_integration], such as layout, shortcuts, options etc.

Commands
---------

| Command                     | List                                                                              |
| ---                         | ---                                                                               |
| `:CocFzfListDiagnostics`    | Equivalent to :CocList diagnostics                                                |
| `:BCocFzfListDiagnostics`   | Equivalent to :CocList diagnostics in the current buffer                          |
| `:CocFzfListExtensions`     | Equivalent to :CocList extensions                                                 |
| `:CocFzfListLocation`       | Equivalent to :CocList location. Toggle preview: '?'. Requires [fzf.vim][fzfvim]  |
| `:CocFzfListOutline`        | Equivalent to :CocList outline, with colors. Requires [ctags][ctags]              |
| `:CocFzfListResume`         | Equivalent to :CocListResume                                                      |
| `:CocFzfListSymbols`        | Equivalent to :CocList symbols                                                    |
| `:CocFzfListServices`       | Equivalent to :CocList services                                                   |

Vimrc Example
---------

```vim
nnoremap <silent> <space>a  :<C-u>CocFzfListDiagnostics<CR>
nnoremap <silent> <space>e  :<C-u>CocFzfListExtensions<CR>
nnoremap <silent> <space>l  :<C-u>CocFzfListLocation<CR>
nnoremap <silent> <space>o  :<C-u>CocFzfListOutline<CR>
nnoremap <silent> <space>p  :<C-u>CocFzfListResume<CR>
nnoremap <silent> <space>s  :<C-u>CocFzfListSymbols<CR>
nnoremap <silent> <space>S  :<C-u>CocFzfListServices<CR>
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
