;; On Windows, I have a lot of things installed via MSYS2. But I don’t
;; add tha to Windows’s PATH because that causes problems for some
;; things. So add it explicitly to Emacs, but only if it exists.
;; Using example from
;; http://ergoemacs.org/emacs/emacs_env_var_paths.html
(when (string-equal system-type "windows-nt")
  (let
      (
       (paths
	'(
	  "C:/msys64/usr/bin"
	  ))
       )
    ;; Have to also set PATH so that shell-command works at all (which
    ;; some things use to e.g. call openssl) even though this will
    ;; confuse any launch MS commands :-/ (e.g.,
    ;; package-refresh-contents)
    (setenv "PATH" (concat (getenv "PATH") (mapconcat 'identity paths ";")))
    (setq exec-path (append exec-path paths))))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default-frame-alist
    (quote
     ((background-color . "black")
      (foreground-color . "green"))))
 '(package-archives
   (quote
    (("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "https://stable.melpa.org/packages/")
     ("melpa" . "https://melpa.org/packages/"))))
 '(package-selected-packages (quote (js2-mode use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq use-package-always-ensure t)
(use-package
    js2-mode
  :mode ("\\.js\\'" . js2-jsx-mode)
  :interpreter ("node" . js2-jsx-mode))

;;; https://emacs.stackexchange.com/a/9953/5172
(defun my-find-file-not-found-set-default-coding-system-hook ()
  "If a file is new, set it to be unix by default because CRLF is annoying."
  (with-current-buffer (current-buffer)
    (setq buffer-file-coding-system 'utf-8-unix)))
(add-hook 'find-file-not-found-functions 'my-find-file-not-found-set-default-coding-system-hook)

;; Preload this file so that I can get to it faster.
(find-file-noselect "~/.emacs.d/init.el")
