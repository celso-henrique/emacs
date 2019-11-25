;;; Celso Henrique .emacs file
;;; package --- Summary

(require 'package)
(package-initialize)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/")) 
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  )
(setq package-enable-at-startup nil)
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
    (markdown-mode flycheck-flow flow-minor-mode prettier-js magit restart-emacs stylus-mode nlinum powerline-evil telephone-line telephone-line-config smart-mode-line-powerline-theme smart-mode-line dtrt-indent flycheck exec-path-from-shell web-mode neotree evil-indent-textobject evil-surround evil-jumper evil-leader use-package helm evil-visual-mark-mode))))
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
  (package-refresh-contents)
  (package-install 'use-package))

(use-package diminish
  :ensure t)

(eval-when-compile
(require 'use-package))
(require 'diminish)
(require 'bind-key)

;; evil mode
(use-package evil
  :ensure t
  :config
  (evil-mode 1))

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
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))

;; for better jsx syntax-highlighting in web-mode
;; - courtesy of Patrick @halbtuerke
(defadvice web-mode-highlight-part (around tweak-jsx activate)
  (if (equal web-mode-content-type "jsx")
    (let ((web-mode-enable-part-face nil))
      ad-do-it)
    ad-do-it))

;; exec-path for macos
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)))

;; js2
(use-package js2-mode
  :ensure t
  :config)
(setq js2-strict-missing-semi-warning nil)

;; prettier
(use-package prettier-js
  :ensure t
  :config
  (setq prettier-js-args '(
    "--trailing-comma" "none"
    "--bracket-spacing" "true"
    "--single-quote"
    "--no-semi"
  ))
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode))

;; rjsx-mode - optmize jsx editing
(use-package rjsx-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))
  (define-key rjsx-mode-map (kbd "C-d") nil)
  (define-key rjsx-mode-map "<" nil))

;; flycheck
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
  '(javascript-jshint)))

;; disable check for html files
(setq-default flycheck-disabled-checkers '(html-tidy))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'rjsx-mode)

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(json-jsonlist)))

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(json-jsonlist)))

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

;; stylus-mode
(use-package stylus-mode 
  :ensure t
  :config)

;; yaml-mode
(use-package yaml-mode 
  :ensure t
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
(setq-default js2-basic-offset 2)

;; powerline
(use-package powerline
  :ensure t
  :config
  (use-package powerline-evil
    :ensure t
    :config
    (powerline-default-theme)
    ))

;; helm
(use-package helm
  :ensure t
  :config
  (helm-mode 1)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-c h g") 'helm-google-suggest))

(customize-set-variable 'helm-ff-lynx-style-map t)

;; escape quits
(bind-key "<escape>" 'isearch-cancel isearch-mode-map)
(bind-key "<escape>" 'helm-keyboard-quit helm-map)
(bind-key "<escape>" 'helm-keyboard-quit helm-comp-read-map)

;; restart emacs
(use-package restart-emacs
  :ensure t
  :config)

;; magit
(use-package magit
  :ensure t
  :config)

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

;; linum
(global-linum-mode t)
(setq linum-format "%d")

;; markdown-mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))


(provide '.emacs)
;;; .emacs ends here
