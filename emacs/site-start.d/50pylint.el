;; -*-emacs-lisp-*-
;;
;; Emacs startup file for the Debian GNU/Linux pylint package
;;
;; Originally contributed by Nils Naumann <naumann@unileoben.ac.at>
;; Modified by Dirk Eddelbuettel <edd@debian.org>
;; Adapted for dh-make by Jim Van Zandt <jrv@vanzandt.mv.com>

;; The pylint package follows the Debian/GNU Linux 'emacsen' policy and
;; byte-compiles its elisp files for each 'emacs flavor' (emacs19,
;; xemacs19, emacs20, xemacs20...).  The compiled code is then
;; installed in a subdirectory of the respective site-lisp directory.

;; Add path for byte-compiled pylint to load-path
(debian-pkg-add-load-path-item
 (concat "/usr/share/"
	 (symbol-name flavor)
	 "/site-lisp/pylint"))

;; Some autoloads
(autoload 'pylint "pylint")
(autoload 'pylint-add-menu-items "pylint")
(autoload 'pylint-add-key-bindings "pylint")

(add-hook 'python-mode-hook 'pylint-add-menu-items)
(add-hook 'python-mode-hook 'pylint-add-key-bindings)
