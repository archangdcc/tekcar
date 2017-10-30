(define (even x)
  (if (eq? x 0) #t (odd (+ x (- 1)))))

(define (odd x)
  (if (eq? x 0) #f (even (+ x (- 1)))))

(odd 13)
