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
    (vterm magit consult marginalia orderless vertico lua-mode auto-package-update markdown-mode prettier-js restart-emacs yaml-mode dockerfile-mode less-css-mode flycheck exec-path-from-shell web-mode use-package evil json-mode vue-mode rjsx-mode js2-mode diminish molokai-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:foreground "#f0f0f0" :background "#666666" :box nil))))
 '(mode-line-inactive ((t (:foreground "#999999" :background "#666666" :box nil)))))

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

;; evil mode
(use-package evil
  :ensure t
  :config
  (evil-mode 1))

;; modern completion UI
(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("<escape>" . keyboard-escape-quit))
  :config
  (vertico-mode 1))

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

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("C-x C-f" . find-file)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-x" . execute-extended-command)))

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

;; rxjs mode
(use-package rjsx-mode
  :ensure t
  :config)
(add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
)
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
  ))
  (add-hook 'rjsx-mode-hook 'prettier-js-mode))

;; flycheck
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'rjsx-mode)
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

;; molokai theme
(use-package molokai-theme 
  :ensure t
  :load-path "themes"
  :init
  (setq molokai-theme-kit t)
  :config
  (load-theme 'molokai t))

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
