(+ 1
   (with-handlers
     ([(lambda (e) (eq? e 2)) (lambda (e) 41)])
     (+ 1 (let ([r (read)])
            (if (eq? r 0) (raise 2) r)))))
