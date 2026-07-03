;;; Celso Henrique .emacs file
;;; package --- Summary

(setq package-enable-at-startup nil)
(require 'package)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

(defun my/package-archive-stale-p ()
  "Return non-nil when package archive metadata should be refreshed."
  (let* ((archive-file (expand-file-name "archives/melpa/archive-contents" package-user-dir))
         (attrs (file-attributes archive-file 'string))
         (mtime (and attrs (file-attribute-modification-time attrs))))
    (or (null package-archive-contents)
        (null mtime)
        (time-less-p mtime (time-subtract (current-time) (days-to-time 7))))))

(when (my/package-archive-stale-p)
  (package-refresh-contents))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" default)))
 '(flycheck-javascript-flow-args nil)
 '(package-selected-packages
   (quote
    (helm doom-modeline nerd-icons eglot treesit-auto vterm magit consult marginalia orderless vertico lua-mode auto-package-update markdown-mode prettier-js restart-emacs yaml-mode dockerfile-mode less-css-mode flycheck exec-path-from-shell web-mode use-package evil json-mode vue-mode diminish))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; backup directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(use-package diminish
  :ensure t)

(eval-when-compile
(require 'use-package))
(require 'diminish)
(require 'bind-key)

;; save minibuffer history
(savehist-mode 1)

;; cozy UI defaults
(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      visible-bell nil
      use-dialog-box nil
      frame-title-format '("%b  |  emacs")
      initial-scratch-message nil)

(menu-bar-mode 1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'blink-cursor-mode)
  (blink-cursor-mode -1))
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))
(global-hl-line-mode 1)
(column-number-mode 1)
(display-time-mode 1)
(show-paren-mode 1)

;; evil mode
(use-package evil
  :ensure t
  :config
  (evil-mode 1))

;; dired with explicit evil-friendly file operations
(use-package dired
  :ensure nil
  :config
  (setq dired-kill-when-opening-new-dired-buffer t
        dired-dwim-target t))

(with-eval-after-load 'dired
  (evil-set-initial-state 'dired-mode 'normal)
  (evil-define-key 'normal dired-mode-map
    (kbd "d") #'dired-flag-file-deletion
    (kbd "x") #'dired-do-flagged-delete
    (kbd "R") #'dired-do-rename
    (kbd "C") #'dired-do-copy
    (kbd "h") #'dired-up-directory
    (kbd "l") #'dired-find-file
    (kbd "RET") #'dired-find-file
    (kbd "^") #'dired-up-directory
    (kbd "+") #'dired-create-directory
    (kbd "g") #'revert-buffer))

;; modern completion UI
(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("<escape>" . keyboard-escape-quit))
  :config
  (setq vertico-cycle t)
  (vertico-mode 1))

(require 'vertico-directory)
(add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;; icons and modeline
(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :init
  (setq doom-modeline-height 28
        doom-modeline-bar-width 4
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-minor-modes nil
        doom-modeline-time t
        doom-modeline-icon t)
  :config
  (doom-modeline-mode 1))

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
   	     ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-x" . execute-extended-command)))

(use-package helm
  :ensure t
  :bind (("C-x C-f" . helm-find-files))
  :config
  (setq helm-split-window-inside-p t
        helm-move-to-line-cycle-in-source t
        helm-ff-file-name-history-use-recentf t))

;; modern JS/TS stack
(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

(use-package eglot
  :ensure t
  :hook ((js-ts-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               '((js-ts-mode typescript-ts-mode tsx-ts-mode)
                 "typescript-language-server" "--stdio")))

(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

(defun my/setup-modern-js-buffer ()
  "Shared setup for modern JavaScript, TypeScript, and TSX buffers."
  (setq-local tab-width 2)
  (setq-local indent-tabs-mode nil)
  (prettier-js-mode 1))

(defun my/eglot-format-buffer-on-save ()
  "Format buffer on save when managed by Eglot."
  (add-hook 'before-save-hook #'eglot-format-buffer nil t))

(add-hook 'js-ts-mode-hook #'my/setup-modern-js-buffer)
(add-hook 'typescript-ts-mode-hook #'my/setup-modern-js-buffer)
(add-hook 'tsx-ts-mode-hook #'my/setup-modern-js-buffer)
(add-hook 'eglot-managed-mode-hook #'my/eglot-format-buffer-on-save)

;; webmode
(use-package web-mode
  :ensure t
  :config)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-css-indent-offset 2))
(add-hook 'web-mode-hook  'my-web-mode-hook)

;; for better jsx syntax-highlighting in web-mode
;; - courtesy of Patrick @halbtuerke
(defun my/web-mode-highlight-part-tweak-jsx (orig-fun &rest args)
  (if (equal web-mode-content-type "jsx")
      (let ((web-mode-enable-part-face nil))
        (apply orig-fun args))
    (apply orig-fun args)))
(advice-add 'web-mode-highlight-part :around #'my/web-mode-highlight-part-tweak-jsx)

;; exec-path for macos
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)))

;; prettier
(use-package prettier-js
  :ensure t
  :config
  (setq prettier-js-args '(
    "--trailing-comma" "none"
    "--bracket-spacing" "true"
    "--single-quote"
  )))

;; flycheck
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)

;; disable noisy or redundant checkers that we do not use
(setq-default flycheck-disabled-checkers
              (append flycheck-disabled-checkers
                      '(javascript-jshint html-tidy json-jsonlist)))

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; use local eslint from node_modules before global
;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))
(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

;; json-mode
(use-package json-mode :ensure t
  :config)

;; yaml-mode
(use-package yaml-mode 
  :ensure t
  :config)

;; lua-mode
(use-package lua-mode
  :ensure t
  :mode ("\\.lua\\'" . lua-mode)
  :config)

;; dockerfile-mode
(use-package dockerfile-mode 
  :ensure t
  :config)

;; less-mode
(use-package less-css-mode 
  :ensure t
  :config)

;; indentation
(setq-default indent-tabs-mode nil
  tab-stop-list ()
  tab-width 2)

;; escape quits
(bind-key "<escape>" 'isearch-cancel isearch-mode-map)
(with-eval-after-load 'helm
  (bind-key "<escape>" 'helm-keyboard-quit helm-map)
  (when (boundp 'helm-read-file-map)
    (bind-key "<escape>" 'helm-keyboard-quit helm-read-file-map)))
(bind-key "<escape>" 'keyboard-escape-quit minibuffer-local-map)
(bind-key "<escape>" 'keyboard-escape-quit minibuffer-local-ns-map)
(bind-key "<escape>" 'keyboard-escape-quit minibuffer-local-completion-map)
(bind-key "<escape>" 'keyboard-escape-quit minibuffer-local-must-match-map)
(bind-key "<escape>" 'keyboard-escape-quit minibuffer-local-isearch-map)

;; restart emacs
(use-package restart-emacs
  :ensure t
  :config)

;; magit
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

;; terminal
(use-package vterm
  :ensure t
  :commands vterm)

(defun my/project-root ()
  (if-let ((project (project-current)))
      (project-root project)
    default-directory))

(defun my/agent-terminal (buffer-name command)
  (let ((default-directory (my/project-root)))
    (vterm buffer-name)
    (vterm-send-string command)
    (vterm-send-return)))

(defun my/codex ()
  (interactive)
  (my/agent-terminal "*codex*" "codex"))

(defun my/claude ()
  (interactive)
  (my/agent-terminal "*claude*" "claude"))

(global-set-key (kbd "C-c a c") #'my/codex)
(global-set-key (kbd "C-c a l") #'my/claude)

;; vue
(use-package vue-mode
  :ensure t
  :config)

;; cozy dark theme
(setq modus-themes-common-palette-overrides
      '((bg-main "#1f1f28")
        (bg-dim "#16161d")
        (bg-alt "#2a2a37")
        (bg-active "#343746")
        (bg-inactive "#252733")
        (fg-main "#dcd7ba")
        (fg-dim "#b7b39a")
        (fg-alt "#938056")
        (accent-0 "#7e9cd8")
        (accent-1 "#98bb6c")
        (accent-2 "#e6c384")
        (accent-3 "#d27e99")
        (bg-region "#3b4252")
        (bg-line-number-active "#2f334d")
        (bg-line-number-inactive "#1a1b26")
        (border-mode-line-active "#7e9cd8")
        (border-mode-line-inactive "#2a2a37")))
(load-theme 'modus-vivendi-tinted t)

;; line numbers
(if (fboundp 'global-display-line-numbers-mode)
    (global-display-line-numbers-mode t)
  (global-linum-mode t)
  (setq linum-format "%d"))

;; markdown-mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;; autoupdate
(use-package auto-package-update
   :ensure t
   :config
   (setq auto-package-update-delete-old-versions t
         auto-package-update-interval 4)
   (auto-package-update-maybe))


(provide '.emacs)
;;; .emacs ends here
