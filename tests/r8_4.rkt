(+ 1
   (with-handlers
     ([(lambda (e) (eq? e 2)) (lambda (e) 41)])
     (+ 1
        (with-handlers
          ([(lambda (e) (eq? e 3)) (lambda (e) (raise 2))])
          (+ 1 (let ([r (read)])
                 (if (eq? r 0) (raise 3) r)))))))
