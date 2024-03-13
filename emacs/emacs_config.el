; This is emacs_config.el, a controlled initialization file for Emacs.
;
; This file should be loaded from .emacs (the main init file) with
; the command:
; 
; (load "~/dotfiles-public/emacs/emacs_config")
; 
; This file can also be byte-compiled to speed up initialization.

;;;; 1. SYSTEM-INDEPENDENT CONFIGURATION
; This contains customizations that don't appear to be available in the
; customization menu.

; Setup automagic loading of auto-fill-mode and flyspell-mode in text
; modes and derivatives.
(defun my-flyspell-mode nil (flyspell-mode 1))
(defun my-auto-fill-mode nil (auto-fill-mode 1))
(add-hook 'text-mode-hook 'my-auto-fill-mode)
(add-hook 'text-mode-hook 'my-flyspell-mode)
; We do this for mail modes too, on the rare occasion we use them
(add-hook 'mail-mode-hook 'my-auto-fill-mode)
(add-hook 'mail-mode-hook 'my-flyspell-mode)

;;; Turn on line numbers
(global-linum-mode 1)
;;; When in C-mode, want all bells and whistles...
(setq c-auto-newline t)

; When writing a new shell script, make it executable
; credit: http://snippets.dzone.com/tag/emacs
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;;; tabs should be 4 characters, damnit!
(setq default-tab-width 4)
(cond ((fboundp 'global-font-lock-mode)
             ;; Turn on font-lock in all modes that support it
             (global-font-lock-mode t)
             ;; Maximum colors
             (setq font-lock-maximum-decoration t)))

; Set the frame title the way we like it.
; Start with the buffer name, then "GNU Emacs $VERSION" and the hostname
; We don't run emacs as root anymore, now that we have tramp.el, so this is much simpler
(setq frame-title-format (concat "%b - GNU Emacs " emacs-version " @ " system-name))

; Put the column number in the modeline
(column-number-mode t)

(if (fboundp 'scroll-bar-mode)(scroll-bar-mode (quote right)))
; Allow ANSI sequences in comint-mode (for running a shell in emacs)
(ansi-color-for-comint-mode-on)

; Add our custom themes
(when (not (boundp 'custom-theme-load-path))
  ;; this means we're Emacs 23, so we need to define it ...
  (defvar custom-theme-load-path ()
  ;; ... and also set custom-theme directory so our themes will work
  (setq custom-theme-directory "~/dotfiles-public/emacs/themes")))
(add-to-list 'custom-theme-load-path
			 "~/dotfiles-public/emacs/themes")


;;;; 2. ADDITIONAL PACKAGES
; A clean way of skipping these packages needs to be devised

; Map CUA keybindings when region is highlighted (something is selected)
; This is valid in emacs 22 and later.
(cua-mode t)

(show-paren-mode 1)

; Use the X11 Clipboard for copy/paste so we play nice with other X apps
(setq x-select-enable-clipboard t)
(require 'generic-x)
; Start the emacs server so we only have one emacs process running at a
; time.
; TODO: put some logic in here so we can handle when the emacs server is running.
(server-start)

;;;; 3. TRAMP CONFIGURATION
; We use the TRAMP package to allow us to edit files remotely, as root
; (via sudo), and even remotely as root (via ssh and root).  The lisp
; below sets up a nice little warning that we're editing a particular
; file as root.
; 
(require 'tramp nil "noerror")

; When we try to to sudo to a host other than localhost, ssh to it first.
(add-to-list 'tramp-default-proxies-alist
			 '("[^localhost]" "root" "/ssh:renomero@%h:"))
(add-to-list 'tramp-default-proxies-alist
			 '(".*\.tcg" "root" "/ssh:rrenomeron@%h:"))

; Place a warning banner at the top of the buffer when we're using tramp.el
; Credit: http://www.emacswiki.org/cgi-bin/wiki/TrampMode#toc5
;
(defun find-file-root-header-warning ()
  "*Display a warning in header line of the current buffer.
   This function is suitable to add to `find-file-root-hook'."
  (string-match "@[[:alnum:]\.]*" buffer-file-name)
  (let* ((warning (concat " WARNING: EDITING FILE AS ROOT " 
				  (match-string 0 buffer-file-name) "!"))
   	 (space (+ 4 (- (window-width) (length warning))))
   	 (bracket (make-string space ? ))
   	 (warning (concat warning bracket)))
    (setq header-line-format
   	  (propertize  warning 'face 'find-file-root-header-face))))

(defun find-file-remote-user-header-warning ()
  "*Display a warning in header line of the current buffer.
   This function is suitable to add to `find-file-root-hook'."
  (string-match "[[:alnum:]\.]*@[[:alnum:]\.]*" buffer-file-name)
  (let* ((warning (concat " NOTE: Editing File as " (match-string 0 buffer-file-name)))
		(space (+ 4 (- (window-width) (length warning))))
		(bracket (make-string space ? ))
		(warning (concat warning bracket)))
    (setq header-line-format
		  (propertize  warning 'face 'find-file-remote-header-face))))

(defun find-file-remote-header-warning ()
  "*Display a warning in header line of the current buffer.
   This function is suitable to add to `find-file-root-hook'."
  (string-match "[[:alnum:]\.]*:[[:alnum:]\.]*" buffer-file-name)
  (let* ((warning (concat " NOTE: Editing File at " (match-string 0 buffer-file-name)))
		(space (+ 4 (- (window-width) (length warning))))
		(bracket (make-string space ? ))
		(warning (concat warning bracket)))
    (setq header-line-format
		  (propertize  warning 'face 'find-file-remote-header-face))))

(defun find-file-hook-root-or-remote-header-warning ()
  (if (and buffer-file-name (string-match "root@" buffer-file-name))
    (find-file-root-header-warning)
  (cond ((and buffer-file-name (string-match "@" buffer-file-name))
    (find-file-remote-user-header-warning))
  ((and buffer-file-name (string-match ":" buffer-file-name))
	(find-file-remote-header-warning)))))
(add-hook 'find-file-hook 'find-file-hook-root-or-remote-header-warning)

 (defface find-file-root-header-face
   '((t (:foreground "white" :background "red3" :weight bold)))
   "*Face use to display header-lines for files opened as root.")
 (defface find-file-remote-header-face
   '((t (:foreground "white" :background "DodgerBlue1" :weight bold)))
   "*Face use to display header-lines for files opened remotely.")



;;;; 4. RECIPES FOR THE .emacs FILE
; Because we run this in front of the customization variables, there
; are some things that have to go in the .emacs file --
; e.g. overriding the customization based on a runtime parameter.  So
; here are some things that you can cut, paste, and uncomment if you
; need them for a particular system.

;;; Use this to enable a better font if you happen to be using Emacs
;;; 23.  Will fail gracefully if you're not.
;;; Credit:
;; (if (not (eq (string-match "23" (emacs-version)) nil))
;;      (push '(font . "Liberation Mono-8") default-frame-alist)
;;      (push '(font . "7x13") default-frame-alist))

;;; Use this to get rid of all color customizations if we're not
;;; running under X.  Useful if you sometimes need to run under a
;;; terminal window.  This uses the assq-delete-all function to remove
;;; the customization bits
;; (if (not window-system) (assq-delete-all 'background-color
;; 										 default-frame-alist))
;; (if (not window-system) (assq-delete-all 'foreground-color
;; 										 default-frame-alist))

