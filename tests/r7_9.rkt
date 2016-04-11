(define (getthird vec)
  (vector-ref vec 3))

(+ (getthird (vector 1 2 3 22 5 6)) (getthird (vector 0 9 8 20)))
