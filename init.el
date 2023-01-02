;; https://emacs.stackexchange.com/questions/34342/is-there-any-downside-to-setting-gc-cons-threshold-very-high-and-collecting-ga
(setq gc-cons-threshold-original gc-cons-threshold)
(setq gc-cons-threshold (* 1024 1024 100))

;; Hide stuff
(menu-bar-mode -1)
(tool-bar-mode -1)

;; Set some nice defaults
(setq-default
 tab-width 2
 ring-bell-function 'ignore ; prevent beep sound.
 initial-major-mode 'org-mode
 initial-scratch-message nil
 create-lockfiles nil ; .#locked-file-name
 confirm-kill-processes nil ; exit emacs without asking to kill processes
 backup-by-copying t ; prevent linked files
 require-final-newline t ; always end files with newline
 delete-old-versions t ; don't ask to delete old backup files
 revert-without-query '(".*") ; `revert-buffer' without confirmation
 use-short-answers t ; e.g. `y-or-n-p' instead of `yes-or-no-p'
 help-window-select t ; Select help window so it's easy to quit it with 'q'
 tab-width 2
 inhibit-startup-message t ; Don't show the startup message...
 inhibit-startup-screen t) ; ... or screen)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Enable some nice builtin features:
;; windmove
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; ido
(ido-mode)
(ido-everywhere 1)

;; Replace buffer menu with ibuffer:
(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq ibuffer-expert t)
(setq ibuffer-show-empty-filter-groups nil)

(add-hook
 'ibuffer-mode-hook
 #'(lambda ()
     (ibuffer-auto-mode 1)
     (ibuffer-switch-to-saved-filter-groups "home")))

;; Activate org-mode
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-log-done t)

(setq org-agenda-files (list "~/org/work.org" "~/org/personal.org"))

;; Make windmove (hopefully) work in Org mode:
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; Make yasnippet work with Org mode:
(add-hook
 'org-mode-hook
 (lambda ()
   (setq-local yas/trigger-key [tab])
   (define-key yas/keymap [tab] 'yas/next-field-or-maybe-expand)))

;; Enable MELPA
(require 'package)
(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/"))

;; (when (not package-archive-contents)
;;    (package-refresh-contents))

;; (setq use-package-always-ensure t)

;; Enable local  packages
(add-to-list 'load-path "/home/slarm/git/emacs/blink-search/")
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)

(add-to-list 'load-path "/home/slarm/git/emacs/vterm-toggle/")

(eval-when-compile
  (require 'use-package))

;;-----------------
;; UI enchancements
;;-----------------

;; Toggle dired as a sidebar
(use-package all-the-icons)
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
(use-package
 dired-sidebar
 :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
 :commands (dired-sidebar-toggle-sidebar)
 :config (setq dired-sidebar-theme 'icons))

;; --------------------------
;; Productivity enchancements
;; --------------------------

(use-package
 which-key
 :diminish which-key-mode
 :config (which-key-mode))

;; Fuzzy search
(use-package blink-search :ensure f :bind ("C-c b" . blink-search))

;; Regexp replace with visual feedback
(use-package
 visual-regexp
 :bind (("C-c r" . 'vr/replace) ("C-c q" . 'vr/query-replace)))

;; Project interaction
(use-package
 projectile
 :diminish projectile-mode
 :hook (after-init . projectile-mode)
 :bind-keymap ("C-c p" . projectile-command-map)
 :init
 (setq projectile-project-search-path
       '(("~/git" . 1) "~/work/" "~/projects/"))
 (setq projectile-switch-project-action #'projectile-dired)
 :custom
 (projectile-completion-system 'ido)
 (projectile-dynamic-mode-line nil)
 (projectile-enable-caching t)
 (projectile-indexing-method 'hybrid)
 (projectile-track-known-projects-automatically nil))

(use-package
 undo-tree
 :diminish undo-tree-mode
 :custom
 (setq undo-tree-history-directory-alist
       '("." . "~/.emacs.d/undo"))
 :config (global-undo-tree-mode))

(use-package vterm :ensure t)
(global-set-key (kbd "C-c C-t") 'vterm)

(use-package
 vterm-toggle
 :bind (("<f2>" . vterm-toggle) ("<S-f2>" . vterm-toggle-cd)))

;; Show vterm at bottom of screen when toggled
(setq vterm-toggle-fullscreen-p nil)
(add-to-list
 'display-buffer-alist
 #'((lambda (buffer-or-name _)
      (let ((buffer (get-buffer buffer-or-name)))
        (with-current-buffer buffer
          (or (equal major-mode 'vterm-mode)
              (string-prefix-p
               vterm-buffer-name
               (buffer-name buffer))))))
    (display-buffer-reuse-window display-buffer-at-bottom)
    (reusable-frames . visible)
    (window-height . 0.3)))

;; -------------------------------
;; Coding: LSP, language modes etc
;; -------------------------------

(use-package elisp-autofmt)

(use-package sr-speedbar :bind (("C-c s" . sr-speedbar-toggle)))

(use-package
 lsp-mode
 :init (setq lsp-keymap-prefix "C-c k")
 :commands (lsp lsp-deferred)
 :hook (lsp-mode . lsp-enable-which-key-integration)
 :custom
 (lsp-diagnostics-provider :capf)
 (lsp-headerline-breadcrumb-enable t)
 (lsp-headerline-breadcrumb-segments
  '(project file symbols))
 (lsp-lens-enable nil)
 (lsp-disabled-clients '((python-mode . pyls)))
 (setq lsp-pyls-plugins-flake8-enabled t)
 :config)

(use-package lsp-ui :hook (lsp-mode . lsp-ui-mode))

;; Bash integration
(add-hook 'sh-mode-hook 'lsp-deferred)

;; Python integration
(use-package
 lsp-pyright
 :hook
 (python-mode
  .
  (lambda ()
    (require 'lsp-pyright)
    (lsp-deferred))))
s;; Golang integration
(add-hook 'go-mode-hook #'lsp-deferred)

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Git integration
(use-package magit :defer t :bind ("C-x g" . magit-status))

;; Text completion
(use-package
 company
 :diminish company-mode
 :bind
 (:map company-active-map ("<tab>" . company-complete-selection))
 (:map lsp-mode-map ("<tab>" . company-indent-or-complete-common))
 :custom
 (company-minimum-prefix-length 1)
 (company-idle-delay 0.01)
 :config)

;; Some nice to have prog modes
(use-package json-mode :hook (json-mode . lsp-deferred))

(use-package yaml-mode)

;; for ansible
(use-package jinja2-mode)
(use-package
 ansible
 :hook ((yaml-mode . ansible) (yaml-mode . lsp-deferred)))

;; Snippets / code templates
(use-package yasnippet :hook (prog-mode . yas-minor-mode))
(use-package
 yasnippet-snippets
 :after (yasnippet)
 :config (yas-reload-all))

(use-package elisp-format)

(add-hook
 'org-mode-hook
 (lambda ()
   (setq-local yas/trigger-key [tab])
   (define-key yas/keymap [tab] 'yas/next-field-or-maybe-expand)))

(use-package esup)
(setq esup-depth 0)
