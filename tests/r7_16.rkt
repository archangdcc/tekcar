(define (if-test n)
   (let ([m (vector 1)])
      (let ([x (vector 1)])
         (let ([y (vector 1)])
            (let ([whocares (vector-set! m 0 n)])
              (let ([whocares2 (vector-set! x 0 1)])
                (let ([whocares3 (vector-set! y 0 1)])
                  (let ([whocares4
                          (if (eq? (vector-ref m 0) 0)
                              (vector-set! (vector-ref x 0) 0 (+ (vector-ref x 0) (vector-ref y 0)))
                              (vector-set! y 0 (+ (vector-ref y 0) (vector-ref x 0))))])
                    (let ([whocares4 (vector-set! x 0 (+ (vector-ref x 0) (vector-ref m 0)))])
                      (let ([whocares5
                              (if (if (eq? (vector-ref m 0) (vector-ref y 0)) #f #t)
                                (vector-set! m 0 (+ (vector-ref m 0)
                                                    (vector-ref x 0)))
                                (vector-set! m 0 (+ (vector-ref m 0)
                                                    (vector-ref y 0))))])
                            (+ (vector-ref x 0) (vector-ref m 0))))))))))))

(if-test 1)
