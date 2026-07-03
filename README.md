# emacs

My personal `.emacs` file.

## Current setup

This config is centered around a lightweight Evil-based editing workflow with
modern minibuffer completion, project search, Git integration, and terminal AI
helpers.

### Core packages

- `evil`: Vim-style modal editing
- `vertico`: minibuffer completion UI
- `orderless`: flexible matching in completion prompts
- `marginalia`: richer annotations in completion lists
- `consult`: buffer switching, search, line jump, imenu, and ripgrep helpers
- `magit`: Git interface inside Emacs
- `vterm`: full terminal inside Emacs
- `flycheck`: on-the-fly diagnostics
- `web-mode`: HTML/templates/web editing
- `rjsx-mode`: JavaScript / JSX editing
- `prettier-js`: formatting for JSX buffers
- `lua-mode`: `.lua` syntax support
- `json-mode`, `yaml-mode`, `dockerfile-mode`, `less-css-mode`, `vue-mode`,
  `markdown-mode`: language/filetype support
- `exec-path-from-shell`: import shell PATH on macOS
- `restart-emacs`: restart helper
- `auto-package-update`: package updates

## Main commands

### Navigation and completion

- `M-x`: command palette with `vertico` completion
- `C-x C-f`: open file
- `C-x b`: switch buffer with `consult-buffer`
- `C-s`: search in current buffer with `consult-line`
- `M-s r`: search in project with `consult-ripgrep`
- `M-s l`: search in current buffer with `consult-line`
- `M-g g`: go to line with `consult-goto-line`
- `M-g i`: go to symbol/section in current buffer with `consult-imenu`
- `M-y`: browse yank history with `consult-yank-pop`
- `ESC`: cancel minibuffer / vertico / isearch

### Git

- `C-x g`: open `magit-status`

### AI terminals

- `C-c a c`: open `vterm` at project root and run `codex`
- `C-c a l`: open `vterm` at project root and run `claude`

## Notes

- The config currently keeps `rjsx-mode` / `js2-mode` for JavaScript and JSX.
- `helm`, `powerline`, and old unused packages were removed from the active
  setup.
- The package bootstrap refreshes package archives automatically when cache
  metadata is stale, which helps avoid MELPA `tar: Not found` errors.
