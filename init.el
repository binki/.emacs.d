;; On Windows, I have a lot of things installed via MSYS2. But I
;; don’t add that to Windows’s PATH because that causes problems for
;; some things. So add it explicitly to Emacs, but only if it exists.
;; Using example from
;; http://ergoemacs.org/emacs/emacs_env_var_paths.html
(when (string-equal system-type "windows-nt")
  (let*
      (
       (paths
	'(
	  "C:/msys64/usr/bin"
	  ))
       (firefox-profile-directory (concat (file-name-as-directory (getenv "HOME")) "AppData/Roaming/Mozilla/Firefox/Profiles/mcchw86t.dev-edition-default/"))
       (firefox-profile-binki-backup-directory (file-name-as-directory (concat firefox-profile-directory "binki-backups")))
       )
    ;; Have to also set PATH so that shell-command works at all (which
    ;; some things use to e.g. call openssl) even though this will
    ;; confuse any launch MS commands :-/ (e.g.,
    ;; package-refresh-contents)
    (setenv "PATH" (mapconcat 'identity (cons (getenv "PATH") paths) ";"))
    (setq exec-path (append exec-path paths))
    ;; Firefox apparently likes to lose profs.js sometimes after a Windows
    ;; BSOD/GSOD. To guard against this, manage backups of it.
    (when (file-directory-p firefox-profile-directory)
      (make-directory firefox-profile-binki-backup-directory t)
      (add-name-to-file
       (concat firefox-profile-directory "prefs.js")
       (concat firefox-profile-binki-backup-directory "prefs.js" (format-time-string ".%Y%m%d"))))))

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
   '((background-color . "black")
     (foreground-color . "green")))
 '(ispell-program-name "aspell")
 '(menu-bar-mode nil)
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "https://stable.melpa.org/packages/")
     ("melpa" . "https://melpa.org/packages/")))
 '(package-selected-packages
   '(activity-watch-mode vc-hgcmd battle-haxe php-mode tide company web-mode company-mode csharp-mode editorconfig js2-mode use-package))
 '(tool-bar-mode nil)
 '(vc-handled-backends '(RCS CVS SVN SCCS SRC Bzr Git Hgcmd Hg)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-added ((t (:inherit diff-changed :extend t :background "#002200" :foreground "#bbffbb"))))
 '(diff-file-header ((t (:extend t :background "grey20" :weight bold))))
 '(diff-refine-added ((t (:inherit diff-refine-changed :background "#004400" :foreground "#aaffff"))))
 '(diff-refine-changed ((t (:background "#444400"))))
 '(diff-refine-removed ((t (:inherit diff-refine-changed :background "#660000"))))
 '(diff-removed ((t (:inherit diff-changed :extend t :background "#330000"))))
 '(js2-error ((t (:foreground "#ffaabb" :underline t)))))

;; binki’s attempt to bootstrap use-package
(unless (fboundp 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package-ensure)
(setq use-package-always-ensure t)
(setq use-package-always-pin "melpa-stable")

(use-package
  activity-watch-mode)
(url-retrieve
  "http://localhost:5600/"
  (lambda (status)
    ;; status will be nil if there are no errors, so enable the mode then
    (if (not status) (global-activity-watch-mode))))

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
  php-mode)

(use-package
  tide
  :config
  (flycheck-add-mode 'typescript-tslint 'web-mode))

(use-package
  company)

;; https://github.com/AlonTzarafi/battle-haxe#installation
(use-package
  haxe-mode
  ;; This is a faked out package, so don’t try to install it. That would give us some other unrelated package.
  :ensure nil
  :mode ("\\.hx\\'" . haxe-mode)
  :no-require t
  :init
  (require 'js)
  (define-derived-mode haxe-mode js-mode "Haxe"
    "Haxe syntax highlighting mode. This is simply using js-mode for now."))
(use-package
  battle-haxe
  ;; Not on melpa-stable
  :pin "melpa"
  :hook (haxe-mode . battle-haxe-mode)
  :bind (;;("M-," . #'pop-global-mark)
	 :map battle-haxe-mode-map
	      ("M-." . #'battle-haxe-goto-definition)))

(use-package
  vc-hgcmd)

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
	"~/OneDrive/.org"
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
  (local-set-key (kbd "M-]") 'tide-references)
  (company-mode))
(add-hook 'typescript-mode-hook #'setup-tide-mode)
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook
 'web-mode-hook
 (lambda ()
   (when (string-equal "tsx" (file-name-extension buffer-file-name))
     (setup-tide-mode))))

(defun binki-windows-bash ()
  (interactive)
  (let ((explicit-shell-file-name "\\msys64\\usr\\bin\\bash"))
    (shell "*windows-bash*")))

;; Get the test failures from node like stack traces to be recognized.
(eval-after-load "compile"
  '(progn
     (dolist
       (regexp
         `((binki-node-stacktrace
             "^ *at [^ ]+ (\\(.*\\):\\([0-9]+\\):\\([0-9]+\\))$"
             1
             2
             3
             2)))
       (add-to-list 'compilation-error-regexp-alist-alist regexp)
       (add-to-list 'compilation-error-regexp-alist (car regexp)))))

;; Treat various MSBuild project-containing files as XML from the get-go.
(add-to-list 'auto-mode-alist '("\\.\\(csproj\\|proj\\|props\\|targets\\|rptproj\\|vbproj\\)\\'" . nxml-mode))
