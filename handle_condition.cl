(define-condition foo () ()
  (:report (lambda (condition stream)
             (princ "Stop FOOing around, numbskull!" stream))))

(error 'foo)
