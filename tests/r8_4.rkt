(let
  ([yin
     ((lambda (cc)
        (let ([_ (print 1)])
          cc))
      (call/cc (lambda (c) c)))])
  (let
    ([yang
       ((lambda (cc)
          (let ([_ (print 0)])
            cc))
        (call/cc (lambda (c) c)))])
    (yin yang)))
