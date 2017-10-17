#lang racket

(provide uncover-null-R3)

(define (mod-rtbl rtbl)  ;; read-write table
  (lambda (instr)
    (match instr
      [`(if (,cmp ,x ,y) ,thns ,thn-live ,elss ,els-live)
        (begin
          (if (eq? (car x) 'var)
            (hash-set!
              rtbl (cadr x)
              (set-add (hash-ref rtbl (cadr x) (set)) 'valid))
            (void))
          (if (eq? (car y) 'var)
            (hash-set!
              rtbl (cadr y)
              (set-add (hash-ref rtbl (cadr y) (set)) 'valid))
            (void))
          (for-each (mod-rtbl rtbl) thns)
          (for-each (mod-rtbl rtbl) elss))]
      [`(cmpq ,x ,y)
        (begin
          (if (eq? (car x) 'var)
            (hash-set!
              rtbl (cadr x)
              (set-add (hash-ref rtbl (cadr x) (set)) 'valid))
            (void))
          (if (eq? (car y) 'var)
            (hash-set!
              rtbl (cadr y)
              (set-add (hash-ref rtbl (cadr y) (set)) 'valid))
            (void)))]
      [`(movzbq ,x (var ,y))  ;; x is always (byte-reg al)
        (hash-set!
          rtbl y
          (set-add (hash-ref rtbl y (set)) 'valid))]
      [`(,op (var ,x) (var ,y))     ;; addq xorq movq
        (hash-set!
          rtbl x
          (set-add (hash-ref rtbl x (set)) y))]
      [`(,op (var ,x) ,y)     ;; addq xorq movq
        (hash-set!
          rtbl x
          (set-add (hash-ref rtbl x (set)) 'valid))]
      [_ (void)])))

(define (build-rtbl rtbl instrs)
  (for-each (mod-rtbl rtbl) instrs)
  rtbl)

(define (init-nulls nulls vars rtbl)
  (for-each
    (lambda (var)
      (let ([v (car var)])
        (if (hash-has-key? rtbl v)
          (void)
          (set-add! nulls v))))
    vars)
  nulls)

(define (find-nulls nulls newnulls rtbl)
  (cond
    [(zero? (set-count nulls)) newnulls]
    [else
      (let ([v (set-first nulls)])
        (set-remove! nulls v)
        (hash-for-each rtbl
          (lambda (u vs)
            (let ([vs (set-remove vs v)])
              (hash-set! rtbl u vs)
              (if (zero? (set-count vs))
                (begin
                  (set-add! nulls u)
                  (set-add! newnulls u)
                  (hash-remove! rtbl u))
                (void)))))
        (find-nulls nulls newnulls rtbl))]))

(define (uncover-null-R3 e)
  (match e
    [`(program (,vars ... ,live-after) ,type . ,instrs)
      (let*
        ([rtbl (build-rtbl (make-hash) instrs)]
         [nulls (init-nulls (mutable-set) vars rtbl)]
         [newnulls (find-nulls (set-copy nulls) (mutable-set) rtbl)]
         [_ (set-union! nulls newnulls)])
        `(program (,@vars ,live-after ,nulls)
                  ,type . ,instrs))]))
