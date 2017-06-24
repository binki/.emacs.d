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
 '(package-archives
   (quote
    (("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "https://stable.melpa.org/packages/")
     ("melpa" . "https://melpa.org/packages/"))))
 '(package-selected-packages (quote (js2-mode use-package)))
 '(tls-program
   (quote
    ("gnutls-cli --x509cafile %t -p %p %h" "gnutls-cli --x509cafile %t -p %p %h --protocols ssl3" "openssl s_client -connect %h:%p -no_ssl2 -ign_eof" "\\msys64\\usr\\bin\\openssl s_client -connect %h:%p -no_ssl2 -ign_eof"))))
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
