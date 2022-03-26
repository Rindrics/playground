(defun http-char (c1 c2)
  (parse-integer (coerce (list c1 c2) 'string)
                 :radix 16))

(princ (http-char #\a #\b))
