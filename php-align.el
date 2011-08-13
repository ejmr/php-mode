;;; php-align.el --- Setup alignment configuration for PHP.

;; Copyright (C) 2011  tetsujin (Yusuke Segawa)

;; Author: tetsujin (Yusuke Segawa) <tetsujin85 (at) gmail.com>
;; Keywords: php languages convenience align
;; URL: https://github.com/tetsujin/emacs-php-align
;; Version: 0.0.1

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; This extension provides alignment for PHP.
;; Note that you must have Font Lock mode enabled.
;;
;; If you don't have php-mode then get from https://github.com/rradonic/php-mode
;; This php-mode has various improvements than original it.
;;
;; Put this file into your load-path.and the following code into your ~/.emacs
;; (add-hook 'php-mode-hook
;;           (require 'php-align)
;;           (lambda () (php-align-setup)))

;;; TODO:
;; - Add test codes using el-expectations.

;;; Code:
(require 'php-mode)
(require 'align)

(defvar php-align-rules-list
  `((php-comma-delimiter
     (regexp   . ",\\(\\s-*\\)[^\\(//\\) \t\n]")
     (repeat   . t)
     (valid    . (lambda() (not (php-align-point-is-string-p))))
     (modes    . '(php-mode)))
    (php-assignment
     (regexp   . ,(concat "[^=!^&*-+<>/.| \t\n]\\(\\s-*[=!^&%*-+<>/.|]*\\)=>?"
                          "\\(\\s-*\\)\\([^= \t\n]\\|$\\)"))
     (group    . (1 2))
     (modes    . '(php-mode))
     (justify  . t)
     (tab-stop . nil))
    (php-single-line-comment
     (regexp  . "\\(\\s-*\\)//")
     (modes   . '(php-mode)))
  )
  "Definition of `align-rules-list' for PHP")

(defvar php-align-region-separate
  (eval-when-compile
    (concat
     "\\("                              ; * blank line
       "^\\s-*$"
     "\\)\\|\\("                        ; * comment start or end line
       "^\\s-*\\(/[/*]\\|\\*/\\)"
     "\\)\\|\\("                        ; * end of line are '[', '(', '{', '}', '/*'
       "\\([[({}]\\|/\\*+\\)\\s-*$"
     "\\)\\|\\("                        ; * beginning of line are ')', '}', ']'
       "^\\s-*[)}]][ \t,;]?\\s-*$"      ;   and trailing character are ',', ';'
     "\\)\\|\\("                        ; * beginning of line are some PHP keywrods
       "^\\s-*"
       "\\("
         "for\\|"
         "foreach\\|"
         "while\\|"
         "if\\|"
         "else\\|"
         "switch\\|"
         "case\\|"
         "break\\|"
         "continue\\|"
         "declare\\|"
         "do"
       "\\)"
       "[ ;]"
     "\\)\\|\\("                        ; * function or method call
       "^\\s-*"
       "\\("
         "\\w\\|[->\\: \t]"
       "\\)+"
       "("
     "\\)"
     ))
  "Regexp of a section of PHP for alignment.")

(defun php-align-setup ()
  "Setup alignment configuration for PHP code."
  (set (make-local-variable 'align-mode-rules-list) php-align-rules-list)
  (set (make-local-variable 'align-region-separate) php-align-region-separate))

(defsubst php-align-face-at-point-in-p (point face-list)
  "Return t if the face of the current POINT is an element of FACE-LIST.
 otherwise nil."
  (consp (memq (get-text-property point 'face) face-list)))

(defun php-align-point-is-comment-p ()
  "Return t if the face of the current position is on the comment syntax."
  (php-align-face-at-point-in-p (point) '(font-lock-comment-face)))

(defun php-align-point-is-string-p ()
  "Return t if the face of the current position is on the string syntax."
  (php-align-face-at-point-in-p (point) '(font-lock-string-face)))

;; Provide:
(provide 'php-align)

;;; php-align.el ends here