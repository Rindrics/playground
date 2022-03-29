(defun http-char (c1 c2 &optional (default #\Space))
  (let ((code (parse-integer (coerce (list c1 c2) 'string)
                 :radix 16
                 :junk-allowed t)))
    (if code
        (code-char code)
      default)))

(defun decode-param (s)
  (labels ((f (lst)
              (when lst
                (case (car lst)
                  (#\% (cons (http-char (cadr lst) (caddr lst))
                             (f (cdddr lst))))
                  (#\+ (cons #\space (f (cdr lst))))
                  (otherwise (cons (car lst) (f (cdr lst))))))))
    (coerce (f (coerce s 'list)) 'string)))

(defun parse-params (s)
  (let ((i1 (position #\= s))
        (i2 (position #\& s)))
    (cond (i1 (cons (cons (intern (string-upcase (subseq s 0 i1))) (decode-param (subseq s (1+ i1) i2)))
                    (and i2 (parse-params (subseq s (1+ i2))))))
          ((equal s "") nil)
          (t s))))

(defun parse-url (s)
  (let* ((url (subseq s
                     (+ 2 (position #\space s))
                     (position #\space s :from-end t)))
         (x (position #\? url)))
    (if x
        (cons (subseq url 0 x) (parse-params (subseq url (1+ x))))
      (cons url '()))))

(defun get-header (stream)
  (let* ((s (read-line stream))
         (h (let ((i (position #\: s)))
              (when i
                (cons (intern (string-upcase (subseq s 0 i)))
                      (subseq s (+ i 2)))))))
    (when h
      (cons h (get-header stream)))))

(defun get-content-params (stream header)
  (let ((length (cdr (assoc 'content-length header))))
    (when length
      (let ((content (make-string (parse-integer length))))
        (read-sequence content stream)
        (parse-params content)))))

(defun hello-request-handler (path header params)
  (if (equal path "greeting")
      (let ((name (assoc 'name params)))
        (if (not name)
            (princ "<html><form>What is your name?<input name='name' /></form></html>")
          (format t "<html>Nice to meet you, ~a!</html>" (cdr name))))
    (princ "Sorry, I don't know that page.")))

(defun serve (request-handler)
  (let ((socket (socket-server 8080)))
    (loop
     (princ socket))))

(princ (http-char #\4 #\1))
(princ (decode-param "foo%3Fbar+baz"))
(princ (parse-params "name=bob+marley%3F&age=25&gender=male"))
(princ (parse-params "hoge"))
(princ (parse-params ""))
(princ (parse-url "GET /hoge.example.com?name=bob+marley%3F&age=25&gender=male HTTP/1.1"))
(princ (parse-url "GET /hoge.example.com HTTP/1.1"))
(princ (get-header (make-string-input-stream "foo: 1
bar: abc, 123
baz: hoge

")))

(princ "
")
(let* ((stream (make-string-input-stream "Host: foo.example
Content-Type: application/x-www-form-urlencoded
Content-Length: 37

name=bob+marley%3F&age=25&gender=male"))
       (header (get-header stream)))
  (princ (get-content-params stream header)))

(princ "
")

(hello-request-handler "hoge" '() '())
(princ "
")
(hello-request-handler "greeting" '() '())
(princ "
")
(hello-request-handler "greeting" '() '((name . "Bob Marley")))

(princ "
")

(serve #'hello-request-handler)
