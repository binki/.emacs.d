;; On Windows, I have a lot of things installed via MSYS2. But I
;; don’t add that to Windows’s PATH because that causes problems for
;; some things. So add it explicitly to Emacs, but only if it exists.
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

;; To get Emacs to prefer Unicode over ShiftJIS
;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Recognize-Coding.html
;; Do this before package stuff so that the package thing does not
;; prompt which encoding I want to use to read packages with.
(prefer-coding-system 'utf-8)

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
 '(package-selected-packages
   (quote
    (tide company web-mode company-mode csharp-mode editorconfig js2-mode use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-added ((t (:inherit diff-changed :background "#335533" :foreground "black")))))

;; binki’s attempt to bootstrap use-package
(unless (fboundp 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq use-package-always-ensure t)
(setq use-package-always-pin "melpa-stable")

(use-package
  js2-mode
  :mode ("\\.js\\'" . js2-jsx-mode)
  :interpreter ("node" . js2-jsx-mode))

(use-package
  editorconfig
  :config (editorconfig-mode 1))

(use-package
  csharp-mode)

(use-package
  tide)

(use-package
  company)

(use-package
  web-mode)

;;; https://emacs.stackexchange.com/a/9953/5172
(defun my-find-file-not-found-set-default-coding-system-hook ()
  "If a file is new, set it to be unix by default because CRLF is annoying."
  (with-current-buffer (current-buffer)
    (setq buffer-file-coding-system 'utf-8-unix)))
(add-hook 'find-file-not-found-functions 'my-find-file-not-found-set-default-coding-system-hook)

;; Preload this file so that I can get to it faster.
(let
    (
     (files
      '(
	"~/.emacs.d/init.el"
	"~/OneDrive/.txt"
	"~/.txt"
	"~/OneDrive/Documents/IISExpress/config/applicationhost.config"
	))
     )
  (dolist (file files nil)
    (when (file-exists-p file)
      (find-file-noselect file))))

;; Automatically update .emacs.d.
(with-current-buffer (find-file-noselect "~/.emacs.d/init.el")
  (vc-pull))
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; https://github.com/ananthakumaran/tide#typescript
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode 1)
  (setq flyecheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode 1)
  (tide-hl-identifier-mode 1)
  (company-mode))
(add-hook 'typescript-mode-hook #'setup-tide-mode)
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook
 'web-mode-hook
 (lambda ()
   (when (string-equal "tsx" (file-name-extension buffer-file-name))
     (setup-tide-mode))))
(flycheck-add-mode 'typescript-tslint 'web-mode)
