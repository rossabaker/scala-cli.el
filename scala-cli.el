;;; scala-cli.el --- run a scala-cli interpreter.

;;; Commentary:
;;
;; Runs an inferior instance of `scala-cli` inside Emacs.
;;
;; Based on https://masteringemacs.org/article/comint-writing-command-interpreter

;;; Code:

(require 'comint)

(defvar scala-cli-file-path "scala-cli"
  "Path to the program used by `run-scala-cli'.")

(defvar scala-cli-arguments nil
  "Command line arguments to pass to `scala-cli'.")

(defvar scala-cli-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    map)
  "Basic mode map for `run-scala-cli'.")

(defvar scala-cli-prompt-regexp "^scala> "
  "Prompt for `run-scala-cli'.")

(defun run-scala-cli ()
  "Run an inferior instance of `scala-cli' inside Emacs."
  (interactive)
  (let* ((scala-cli-program scala-cli-file-path)
         (buffer (comint-check-proc "scala-cli")))
    ;; pop to the "*scala-cli*" buffer if the process is dead, the
    ;; buffer is missing or it's got the wrong mode.
    (pop-to-buffer-same-window
     (if (or buffer (not (derived-mode-p 'scala-cli-mode))
             (comint-check-proc (current-buffer)))
         (get-buffer-create (or buffer "*scala-cli*"))
       (current-buffer)))
    ;; create the comint process if there is no buffer.
    (unless buffer
      (apply 'make-comint-in-buffer "scala-cli" buffer
             scala-cli-program nil "repl" scala-cli-arguments)
      (scala-cli-mode))))

(defun scala-cli--repl-initialize ()
  "Helper function to initialize scala-cli."
  (setq comint-process-echoes t)
  (setq comint-use-prompt-regexp t))

(define-derived-mode scala-cli-repl-mode comint-mode "scala-cli"
  "Major mode for `run-scala-cli'.

\\<scala-cli-mode-map>"
  nil "scala-cli"
  (setq comint-prompt-regexp scala-cli-prompt-regexp)
  ;; this makes it read only; a contentious subject as some prefer the
  ;; buffer to be overwritable.
  (setq comint-prompt-read-only t)
  ;; this makes it so commands like M-{ and M-} work.
  (set (make-local-variable 'paragraph-separate) "\\'")
  (set (make-local-variable 'paragraph-start) scala-cli-prompt-regexp))

(add-hook 'scala-cli-mode-hook 'scala-cli--initialize)

(provide 'scala-cli)
