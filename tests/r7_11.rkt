(define (getsec vec)
  (let ([junk (vector (vector (vector 1 2 3) (vector 1 2 3) (vector 1 2 3))  (vector (vector 1 2 3) (vector 1 2 3) (vector 1 2 3)))]) 
    (vector-ref vec 1)))

(let ([recur (vector 0 42)])
  (let ([dum (vector-set! recur 0 recur)])
    (getsec recur)))
