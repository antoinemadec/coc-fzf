# fzf :heart: coc.nvim

Use [FZF][fzf] instead of [coc.nvim][coc.nvim] built-in fuzzy finder.

![](https://raw.githubusercontent.com/antoinemadec/gif/master/coc_fzf.gif)

## Rationale

This plugin uses [FZF][fzf] fuzzy finder in place of [Coc][coc.nvim]'s built-in [CocList sources][coc_sources] as well as Coc's jumps (definition, reference etc).\
It makes the interaction with Coc easier when you are used to FZF.

The main features are:
- FZF preview
- FZF bindings for splits and tabs
- FZF layout (floating windows etc)
- FZF multi-select to populate the quickfix window

It was inspired by [Robert Buhren's functions][RobertBuhren] and [coc-denite][coc_denite].

## Installation

Make sure to have the following plugins in your **vimrc**:
```vim
Plug 'junegunn/fzf', {'dir': '~/.fzf','do': './install --all'}
Plug 'junegunn/fzf.vim' " needed for previews
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'antoinemadec/coc-fzf'
```

Or, if you prefer using the **release** branch:
```vim
Plug 'junegunn/fzf', {'dir': '~/.fzf','do': './install --all'}
Plug 'junegunn/fzf.vim' " needed for previews
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
```

Also consider installing [bat][bat] for colorful previews.

## Commands

| Command                       | List                       |
| ---                           | ---                        |
| `:CocFzfList`                 | List all list sources      |
| `:CocFzfList --original-only` | List only original sources |
| `:CocFzfList {source}`        | Run a list source          |
| `:CocFzfListResume`           | Retrieve last list source  |

### Original Sources

These are the list sources implemented with FZF:

| Source                            | List                                                          | Preview | Multi-select | Vim support |
| ---                               | ---                                                           | ---     | ---          | ---         |
| `actions`                         | Like :CocList actions                                         | -       | -            | ✅          |
| `commands`                        | Like :CocList commands                                        | -       | -            | ✅          |
| `diagnostics`                     | Like :CocList diagnostics                                     | ✅      | ✅           | ✅          |
| `diagnostics --current-buf`       | Like :CocList diagnostics in the current buffer only          | ✅      | ✅           | ✅          |
| `issues`                          | Like :CocList issues. Requires [coc-git][coc-git]             | ✅      | -            | ✅          |
| `location`                        | Like :CocList location. Requires [fzf.vim][fzfvim]            | ✅      | ✅           | ✅          |
| `outline`                         | Like :CocList outline, with colors. Requires [ctags][ctags]   | -       | ✅           | ✅          |
| `output`                          | Like :CocList output                                          | -       | ✅           | ✅          |
| `services`                        | Like :CocList services                                        | -       | -            | ✅          |
| `snippets `                       | Like :CocList snippets. Requires [coc-snippets][coc-snippets] | ✅      | ✅           | ✅          |
| `sources `                        | Like :CocList sources                                         | -       | -            | ✅          |
| `symbols ({query})`               | Like :CocList symbols                                         | ✅      | ✅           | ❌          |
| `symbols --kind {kind} ({query})` | Like :CocList symbols -kind {kind}                            | ✅      | ✅           | ❌          |
| `yank`                            | Like :CocList yank. Requires [coc-yank][coc-yank]             | ✅      | ✅           | ✅          |

FZF bindings (default):
- **ctrl-t**: open in tab
- **ctrl-x**: open in vertical split
- **ctrl-s**: open in horizontal split
- **tab**: multi-select, populate quickfix window
- **?**: toggle preview window

### Wrapper Sources

Not every list source is implementable with FZF.\
For those sources, `:CocFzfList` acts as a wrapper calling `:CocList`

Wrapper Sources appear with the **[wrapper]** mention when running `:CocFzfList`

### Add/Delete Sources
```vim
" add_list_source(name, description, command)
call coc_fzf#common#add_list_source('fzf-buffers', 'display open buffers', 'Buffers')

" delete_list_source(name)
call coc_fzf#common#delete_list_source('fzf-buffers')
```

## Options

| Option                         | Type   | Description                                                    | Default value               |
| ---                            | ---    | ---                                                            | ---                         |
| `g:coc_fzf_preview_toggle_key` | string | Change the key to toggle the preview window                    | `'?'`                       |
| `g:coc_fzf_preview`            | string | Change the preview window position                             | `'up:50%'`                  |
| `g:coc_fzf_opts`               | array  | Pass additional parameters to fzf, e.g. `['--layout=reverse']` | `['--layout=reverse-list']` |

## Vimrc Example
```vim
" allow to scroll in the preview
set mouse=a

" mappings
nnoremap <silent> <space><space> :<C-u>CocFzfList<CR>
nnoremap <silent> <space>a       :<C-u>CocFzfList diagnostics<CR>
nnoremap <silent> <space>b       :<C-u>CocFzfList diagnostics --current-buf<CR>
nnoremap <silent> <space>c       :<C-u>CocFzfList commands<CR>
nnoremap <silent> <space>e       :<C-u>CocFzfList extensions<CR>
nnoremap <silent> <space>l       :<C-u>CocFzfList location<CR>
nnoremap <silent> <space>o       :<C-u>CocFzfList outline<CR>
nnoremap <silent> <space>s       :<C-u>CocFzfList symbols<CR>
nnoremap <silent> <space>p       :<C-u>CocFzfListResume<CR>
```

## FAQ

**Q**: How to get the FZF floating window?\
**A**: You can look at [FZF Vim integration][fzf_vim_integration]:
```vim
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
```
**Q**: How to see references, definitions etc in a FZF window?\
**A**: It is already supported by default, just make sure to have the default coc mappings:
```vim
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
```
**Q**: How to get colors in previews?\
**A**: Install [bat][bat].

**Q**: CocFzf looks different from my other Fzf commands. How to make it the same?\
**A**: By default, CocFzf tries to mimic CocList. Here is how to change this:
```vim
let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []
```

License
-------

MIT

[fzf]:                 https://github.com/junegunn/fzf
[fzf_vim_integration]: https://github.com/junegunn/fzf/blob/master/README-VIM.md
[coc.nvim]:            https://github.com/neoclide/coc.nvim
[coc_sources]:         https://github.com/neoclide/coc.nvim/wiki/Using-coc-list#builtin-list-sources
[RobertBuhren]:        https://gist.github.com/RobertBuhren/02e05506255c667c0038ce74ee1cef96
[coc_denite]:          https://github.com/neoclide/coc-denite
[ctags]:               https://github.com/universal-ctags/ctags
[fzfvim]:              https://github.com/junegunn/fzf.vim
[coc-snippets]:        https://github.com/neoclide/coc-snippets
[coc-yank]:            https://github.com/neoclide/coc-yank
[bat]:                 https://github.com/sharkdp/bat
[coc-git]:             https://github.com/neoclide/coc-git
