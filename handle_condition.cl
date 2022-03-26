(define-condition foo () ()
  (:report (lambda (condition stream)
             (princ "Stop FOOing around, numbskull!" stream))))

(defun bad-function ()
  (error 'foo))

(bad-function)
