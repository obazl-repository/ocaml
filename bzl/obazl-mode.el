;; obazl minor mode

(defun obazl-read-test-spec ()
  "Read the (* TEST ... *) spec."
  (interactive)
  (lisp-mode)
  (goto-char (point-min))
  (let ((beg (point)))
    (forward-list)
    (letrec ((dsl (buffer-substring-no-properties beg (point)))
             (dsl-lines (split-string dsl "\n"))
             (spec (read dsl)))
      (message "dsl list?: %s" (listp spec))
      (dolist (tok dsl-lines)
        (message "%s\n" tok))
      )))

(defun obazl-gen-repl-tests () ;; (directory)
  "List the .ml files in current directory."
  (interactive) ; "DDirectory name: ")
  (let ((ml-files-list
         (directory-files
          (file-name-directory buffer-file-name)
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
    (insert "load(\"//bzl/rules/test:rules.bzl\", \"repl_test\")\n")
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
