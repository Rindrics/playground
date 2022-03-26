(defun http-char (c1 c2)
  (let ((code (parse-integer (coerce (list c1 c2) 'string)
                 :radix 16
                 :junk-allowed t)))
    code))

(princ (http-char #\2 #\h))
