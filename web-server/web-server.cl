(defun http-char (c1 c2)
  (coerce (list c1 c2) 'string))

(princ (http-char #\a #\b))
