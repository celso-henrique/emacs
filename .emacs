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
;; macOS PATH (NODE / PRETTIER / ESLINT)
;; --------------------------------------------------

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-env "PATH")
    (exec-path-from-shell-copy-env "NODE_PATH")))

;; --------------------------------------------------
;; NODE_MODULES/.BIN NO PATH (FORMA CORRETA)
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
  :config
  (evil-mode 1))

;; ESC sempre cancela tudo
(global-set-key (kbd "<escape>") 'keyboard-quit)

;; --------------------------------------------------
;; MODOS DE EDIÇÃO
;; --------------------------------------------------

;; JS / JSX
(use-package rjsx-mode
  :mode ("\\.js\\'" "\\.jsx\\'"))

;; TypeScript (sem JSX)
(use-package typescript-mode
  :mode ("\\.ts\\'")
  :config
  (setq typescript-indent-level 2))

;; TSX → WEB-MODE (correto)
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
;; PRETTIER (LOCAL DO PROJETO)
;; --------------------------------------------------

(use-package prettier-js
  :diminish prettier-js-mode
  :config
  ;; NÃO força global — usa node_modules/.bin/prettier
  (setq prettier-js-command "prettier")

  (add-hook 'rjsx-mode-hook #'prettier-js-mode)
  (add-hook 'typescript-mode-hook #'prettier-js-mode)
  (add-hook 'web-mode-hook #'prettier-js-mode)

  ;; format on save
  (add-hook 'prettier-js-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'prettier-js nil t))))

;; --------------------------------------------------
;; FLYCHECK + ESLINT LOCAL
;; --------------------------------------------------

(use-package flycheck
  :init
  (global-flycheck-mode))

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
;; DESABILITAR COISAS QUE QUEBRAM INDENTAÇÃO
;; --------------------------------------------------

(use-package dtrt-indent
  :config
  (add-hook 'typescript-mode-hook (lambda () (dtrt-indent-mode -1)))
  (add-hook 'web-mode-hook (lambda () (dtrt-indent-mode -1))))

(setq electric-indent-mode nil)

;; --------------------------------------------------
;; INDENTAÇÃO GLOBAL
;; --------------------------------------------------

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(setq js-indent-level 2)
(setq js2-basic-offset 2)
(setq typescript-indent-level 2)

;; --------------------------------------------------
;; HELM
;; --------------------------------------------------

(use-package helm
  :config
  (helm-mode 1)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files))

;; ESC fecha Helm SEMPRE
(with-eval-after-load 'helm
  (define-key helm-map (kbd "<escape>") 'helm-keyboard-quit))

;; --------------------------------------------------
;; UI
;; --------------------------------------------------

(use-package molokai-theme
  :config
  (load-theme 'molokai t))

(use-package restart-emacs)

;; --------------------------------------------------
;; FINAL
;; --------------------------------------------------

(provide '.emacs)
;;; .emacs ends here
