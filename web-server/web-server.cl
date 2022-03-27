(defun http-char (c1 c2 &optional (default #\Space))
  (let ((code (parse-integer (coerce (list c1 c2) 'string)
                 :radix 16
                 :junk-allowed t)))
    (if code
        (code-char code)
      default)))

(defun decode-param (s)
  (labels ((f (lst)
              lst))
    (coerce (f (coerce s 'list)) 'string)))

(princ (http-char #\4 #\1))
(princ (decode-param "foo"))
