;; obazl minor mode

;; if (* TEST *) then
;;    if ref file then expect_test else ocaml_test

(defun emit-cmt (line bazel-file)
  (write-region (format "# %s\n" line) nil bazel-file t))

(defun four-star (lines bazel-file)
  (write-region (format "#4 %s\n" (car lines)) nil bazel-file t)
  (letrec ((handler (lambda (lines)
                      ;; (write-region (format "#---- %s\n" (car lines))
                      ;;               nil bazel-file t)
                      (when lines
                        (cond
                         ((string-match " *\\*)" (car lines))
                          ;; eospec
                          (write-region (format "# %s\n" (car lines))
                                        nil bazel-file t)
                          (cdr lines))
                         ((string-match "\s-*\\* +" (car lines))
                          ;; end
                          ;; (write-region (format "#X-- %s\n" (car lines))
                          ;;               nil bazel-file t)
                          lines)
                         ((string-match "\s-*\\*\\* +" (car lines))
                          ;; end
                          ;; (write-region (format "#XX- %s\n" (car lines))
                          ;;               nil bazel-file t)
                          lines)
                         ((string-match "\s-*\\*\\*\\* +" (car lines))
                          ;; end
                          ;; (write-region (format "#XXX %s\n" (car lines))
                          ;;               nil bazel-file t)
                          lines)
                         ((string-match "\s-*\\*\\*\\*\\* +" (car lines))
                          ;; end
                          ;; (write-region (format "#XXX %s\n" (car lines))
                          ;;               nil bazel-file t)
                          lines)
                         ;; ((string-match "\s-*\\*\\*\\*\* +" (car lines))
                         ;;  (let ((tail
                         ;;         (four-star lines bazel-file)))
                         ;;    (funcall handler tail)))
                         (t
                          (progn
                            (write-region (format "#4- %s\n" (car lines))
                                          nil bazel-file t))
                          (funcall handler (cdr lines))))))))
    (funcall handler (cdr lines))))

(defun three-star (lines bazel-file)
  (write-region (format "#3 %s\n" (car lines)) nil bazel-file t)
  (letrec ((handler (lambda (lines)
                      ;; (write-region (format "#--- %s\n" (car lines))
                      ;;               nil bazel-file t)
                      (when lines
                        (cond
                         ((string-match " *\\*)" (car lines))
                          ;; eospec
                          (write-region (format "# %s\n" (car lines))
                                        nil bazel-file t)
                          (cdr lines))
                         ((string-match "\s-*\\* +" (car lines))
                          ;; end
                          (write-region (format "#X-- %s\n" (car lines))
                                        nil bazel-file t)
                          lines)
                         ((string-match "\s-*\\*\\* +" (car lines))
                          ;; end
                          (write-region (format "#XX- %s\n" (car lines))
                                        nil bazel-file t)
                          lines)
                         ((string-match "\s-*\\*\\*\\* +" (car lines))
                          ;; new three
                          ;; (write-region (format "#XXX %s\n" (car lines))
                          ;;               nil bazel-file t)
                          lines)
                         ((string-match "\s-*\\*\\*\\*\* +" (car lines))
                          (let ((tail
                                 (four-star lines bazel-file)))
                            (funcall handler tail)))
                         (t
                          (progn
                            (write-region (format "#3- %s\n" (car lines))
                                          nil bazel-file t))
                          (funcall handler (cdr lines))))))))
    (funcall handler (cdr lines))))

(defun two-star (lines bazel-file)
  (write-region (format "#2 %s\n" (car lines)) nil bazel-file t)
  (letrec ((handler (lambda (lines)
                      ;; (write-region (format "#-- %s\n" (car lines))
                      ;;               nil bazel-file t)
                      (when lines
                        (cond
                         ((string-match " *\\*)" (car lines))
                          ;; eospec
                          (write-region (format "# %s\n" (car lines))
                                        nil bazel-file t)
                          (cdr lines))
                         ((string-match " *\\*\\*\\* +" (car lines))
                          (let ((tail
                                 (three-star lines bazel-file)))
                            (funcall handler tail)))
                         ((string-match " *\\*\\* +" (car lines))
                          ;; end of this two-star
                          (write-region (format "#XX %s\n" (car lines))
                                        nil bazel-file t)
                          lines)
                         ((string-match " *\\* +" (car lines))
                          ;; end of this two-star
                          (write-region (format "#X- %s\n" (car lines))
                                        nil bazel-file t)
                          lines)
                         (t
                          (progn
                            (write-region (format "#2- %s\n" (car lines))
                                          nil bazel-file t))
                          (funcall handler (cdr lines))))))))
    (funcall handler (cdr lines))))

(defun one-star (lines bazel-file)
  (write-region (format "#1 %s\n" (car lines)) nil bazel-file t)
  (letrec ((handler (lambda (lines)
                      ;; (write-region (format "#- %s\n" (car lines))
                      ;;               nil bazel-file t)
                      (when lines
                        (cond
                         ((string-match " *\\*)" (car lines))
                          ;; eospec
                          (write-region (format "# %s\n" (car lines))
                                        nil bazel-file t)
                          (cdr lines))
                         ((string-match "\s-*\\*\\*\\* +" (car lines))
                          (error "Found *** directly after *"))
                         ((string-match " *\\*\\* +" (car lines))
                          (let ((tail
                                 (two-star lines bazel-file)))
                            (funcall handler tail)))
                         ((string-match " *\\* +" (car lines))
                          ;; end of this one-star
                          (write-region (format "#X %s\n" (car lines))
                                        nil bazel-file t)
                          lines)
                         (t
                          (progn
                            (write-region (format "#1- %s\n" (car lines))
                                          nil bazel-file t))
                          (funcall handler (cdr lines))))))))
    (funcall handler (cdr lines))))

(defun obazl-convert-test-spec (fname bazel-file)
  "Read the (* TEST ... *) spec."
  ;; (interactive)
  (message "converting...")
  (goto-char (point-min))
  (let ((beg (point)))
    (forward-list)
    (letrec ((dsl (buffer-substring-no-properties beg (point)))
             (dsl-lines (split-string dsl "\n"))
             (spec (read dsl)))
      ;; (message "dsl list?: %s" (listp spec))
      (message "dsl is string? %s" (stringp dsl))
      (write-region (format "\n## %s\n" fname) nil bazel-file t)
      ;; (dolist (l dsl-lines)
      ;;   (write-region (format "# %s\n" l) nil bazel-file t))
      (letrec ((handler (lambda (lines)
                          (when lines
                            (message "line: %s" (car lines))
                            (cond
                             ((string-match "(\\* *TEST" (car lines))
                              (progn
                                (emit-cmt (car lines) bazel-file)
                                (funcall handler (cdr lines))))
                             ((string-match " *\\* +" (car lines))
                              (let ((tail
                                     (one-star lines bazel-file)))
                                (funcall handler tail)))
                             (t
                              (progn
                                (write-region (format "#0 %s\n" (car lines))
                                              nil bazel-file t))
                              (funcall handler (cdr lines))))))))
         (funcall handler dsl-lines))
      )))

(defun obazl-convert-tests ()
  "Convert tests in current directory."
  (interactive)
  ;; (message "dired cwd: %s" (dired-current-directory t))
  ;; (message "file at point: %s" (dired-get-filename 'no-dir))
  (letrec ((this-dir (dired-current-directory t))
           (files-list
            (directory-files this-dir
                             nil ;; relative paths
                             ".*\.ml[ily]?$"
                             ;; assumption: no directory names match
                             ))
           (bazel-file (format "%sBUILD.obazl.bazel" this-dir))
           (oldbuf (current-buffer))
           (work-buf (generate-new-buffer "obazl")))
    (message "this dir: %s" this-dir)
    (save-current-buffer
      (set-buffer work-buf)
      (lisp-mode)
      (write-region
       (concat (format "## %s\n\n" this-dir)
               ;; FIXME: dsl parser must discover needed rules
               "load(\"//test:rules.bzl\", \"repl_test\")\n")
       nil bazel-file)
      (dolist (f files-list)
        (let ((relf (format "%s%s" this-dir f)))
          (message "\nFILE: %s" relf)
          (erase-buffer)
          (insert-file-contents relf)
          (goto-char (point-min))
          (let ((first-line (thing-at-point 'line)))
            ;; (message "line 1: %s" first-line)
            (if (string-match "(\* *TEST" first-line)
                (obazl-convert-test-spec f bazel-file))
            ))))
    )
  )

(defun obazl-gen-repl-tests () ;; (directory)
  "List the .ml files in current directory."
  (interactive) ; "DDirectory name: ")
  (let ((this-dir (file-name-directory buffer-file-name))
        (ml-files-list
         (directory-files
          this-dir
          nil ;; relative paths
          ".*.ml"
          ))
        (bufname (buffer-name)))
    (message "ml files: %s" ml-files-list)
    ;;TODO: avoid directories named *.ml

    (write-file "BUILD.old.bazel")
    (kill-buffer (buffer-name))
    (find-file "BUILD.bazel")

    (goto-char (point-min))
    (erase-buffer)
    (insert "load(\"//test:rules.bzl\", \"repl_test\")\n")
    (insert "\n")

    (insert "test_suite(\n")
    (insert "    name  = \"tests\",\n")
    (insert "    tests = [\n")
    (dolist (ml-file ml-files-list)
      (insert (format "        \"%s_test\",\n"
                      (file-name-sans-extension ml-file))))
    (insert "    ]\n")
    (insert ")\n")

    (dolist (ml-file ml-files-list)
      (insert "\n")
      (insert "repl_test(\n")
      (insert (format "    name    = \"%s_test\",\n"
                      (file-name-sans-extension ml-file)))
      (insert (format "    script  = \"%s\",\n" ml-file))
      (insert (format "    timeout = \"short\",\n"))
      (insert (format "    tags    = [\"repl\"]\n"))
      (insert ")\n")
      )
    (save-buffer)
    (goto-char (point-min))
    (message "inserted %d targets" (length ml-files-list))
    ))

(define-minor-mode obazl-minor-mode
  "Toggles global obazl-minor-mode."
  :init-value nil   ; Initial value, nil for disabled
  :global t
  ;; :group 'bazel
  :lighter " obazl"
  :keymap
  (list (cons (kbd "C-c C-. t") (lambda ()
                              (interactive)
                              (message "obazl key binding used!"))))

  (if obazl-minor-mode
      (message "obazl-basic-mode activated!")
    (message "obazl-basic-mode deactivated!")))

(add-hook 'obazl-minor-mode-hook (lambda () (message "Hook was executed!")))
(add-hook 'obazl-minor-mode-on-hook (lambda () (message "obazl turned on!")))
(add-hook 'obazl-minor-mode-off-hook (lambda () (message "obazl turned off!")))

(provide 'obazl-minor-mode)
