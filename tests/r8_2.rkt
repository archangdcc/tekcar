(+ 1
   (with-handlers
     ([(lambda (e) (eq? e 2)) (lambda (e) 41)])
     (+ 1 (raise 2))))
