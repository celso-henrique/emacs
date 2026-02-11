;;; Celso Henrique .emacs
;;; ======================

;; --------------------------------------------------
;; PACKAGE SYSTEM
;; --------------------------------------------------

(require 'package)
(setq package-enable-at-startup nil)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(package-initialize)

;; --------------------------------------------------
;; use-package
;; --------------------------------------------------

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))
(require 'bind-key)

(setq use-package-always-ensure t)

;; --------------------------------------------------
;; PERFORMANCE
;; --------------------------------------------------

(setq gc-cons-threshold (* 50 1000 1000))
(setq read-process-output-max (* 1024 1024))
(setq inhibit-startup-screen t)

;; Smooth scroll
(setq scroll-conservatively 101)
(setq scroll-margin 8)
(setq scroll-step 1)

;; --------------------------------------------------
;; macOS PATH
;; --------------------------------------------------

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-env "PATH")
    (exec-path-from-shell-copy-env "NODE_PATH")))

;; --------------------------------------------------
;; NODE_MODULES/.BIN
;; --------------------------------------------------

(use-package add-node-modules-path
  :hook
  ((rjsx-mode
    typescript-mode
    web-mode) . add-node-modules-path))

;; --------------------------------------------------
;; EVIL
;; --------------------------------------------------

(use-package evil
  :init
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(global-set-key (kbd "<escape>") 'keyboard-quit)

;; --------------------------------------------------
;; LINE NUMBERS
;; --------------------------------------------------

(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

(dolist (mode '(term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                helm-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; --------------------------------------------------
;; WHICH-KEY
;; --------------------------------------------------

(use-package which-key
  :config
  (which-key-mode 1))

;; --------------------------------------------------
;; TREE-SITTER (highlight moderno)
;; --------------------------------------------------

(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

;; --------------------------------------------------
;; MODOS DE EDIÇÃO
;; --------------------------------------------------

(use-package rjsx-mode
  :mode ("\\.js\\'" "\\.jsx\\'"))

(use-package typescript-mode
  :mode ("\\.ts\\'")
  :config
  (setq typescript-indent-level 2))

(use-package web-mode
  :mode ("\\.tsx\\'")
  :config
  (setq web-mode-content-types-alist
        '(("jsx" . "\\.tsx\\'")))
  (setq web-mode-markup-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-script-indent-offset 2
        web-mode-css-indent-offset 2
        indent-tabs-mode nil))

;; --------------------------------------------------
;; PRETTIER
;; --------------------------------------------------

(use-package prettier-js
  :diminish prettier-js-mode
  :config
  (setq prettier-js-command "prettier")

  (dolist (hook '(rjsx-mode-hook
                  typescript-mode-hook
                  web-mode-hook))
    (add-hook hook #'prettier-js-mode))

  (add-hook 'prettier-js-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'prettier-js nil t))))

;; --------------------------------------------------
;; FLYCHECK + ESLINT
;; --------------------------------------------------

(use-package flycheck
  :init
  (global-flycheck-mode)
  :config
  (setq flycheck-indication-mode 'right-fringe)
  (setq flycheck-idle-change-delay 0.5))

(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name
                       "node_modules/eslint/bin/eslint.js" root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

;; --------------------------------------------------
;; INDENTAÇÃO
;; --------------------------------------------------

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(setq js-indent-level 2)
(setq js2-basic-offset 2)
(setq typescript-indent-level 2)

(setq electric-indent-mode nil)

;; --------------------------------------------------
;; HELM
;; --------------------------------------------------

(use-package helm
  :config
  (helm-mode 1)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files))

(with-eval-after-load 'helm
  (define-key helm-map (kbd "<escape>") 'helm-keyboard-quit))

;; --------------------------------------------------
;; THEME
;; --------------------------------------------------

(use-package doom-themes
  :config
  (load-theme 'doom-tokyo-night t)
  (doom-themes-org-config))

;; --------------------------------------------------
;; DOOM MODELINE
;; --------------------------------------------------

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 4)
  (doom-modeline-minor-modes nil)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-enable-word-count nil))

(use-package all-the-icons)

;; --------------------------------------------------
;; GIT
;; --------------------------------------------------

(use-package git-gutter
  :init
  (global-git-gutter-mode +1))

;; --------------------------------------------------
;; QUALITY OF LIFE
;; --------------------------------------------------

(global-hl-line-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(column-number-mode 1)

(setq backup-directory-alist `(("." . "~/.emacs-saves")))
(setq auto-save-default nil)

;; --------------------------------------------------
;; FINAL
;; --------------------------------------------------

(provide '.emacs)
;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(git-gutter all-the-icons doom-modeline doom-themes treesit-auto which-key zig-mode yaml-mode web-mode vue-mode typescript-mode stylus-mode rjsx-mode restart-emacs prettier-js powerline-evil popup origami molokai-theme markdown-mode json-mode helm flycheck exec-path-from-shell dtrt-indent dockerfile-mode diminish coverlay auto-package-update add-node-modules-path)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
