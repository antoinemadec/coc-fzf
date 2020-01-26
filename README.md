fzf :heart: coc.nvim
===============

Use [fzf][fzf] instead of [coc.nvim][coc.nvim] built-in fuzzy finder.

Rationale
---------

Forked from those [RobertBuhren][functions], this plugin aims
to use [fzf][fzf] for CocList sources when possible.

The goal is to keep the [coc.nvim][coc.nvim] style and leverage your FZF Vim [fzf_vim_integration][integration], such as layout, shortcuts, options etc.

Commands
---------

| Command                     | List                                |
| ---                         | ---                                 |
| `:CocFzfListDiagnostics`    | Equvalent to :CocList diagnostics   |

License
-------

MIT

[fzf_vim_integration]: https://github.com/junegunn/fzf/blob/master/README-VIM.md
[fzf]:                 https://github.com/junegunn/fzf
[coc.nvim]:            https://github.com/neoclide/coc.nvim
[RobertBuhren]:        https://gist.github.com/RobertBuhren/02e05506255c667c0038ce74ee1cef96
