#lang racket

(require "../utilities.rkt")

(provide typecheck-R3)

(define (typecheck env)
  (lambda (e)
    (match e
      [`(program ,(app (typecheck '()) e t))
       `(program (type ,t) ,e)]
      [(? fixnum?)
       (values `(has-type ,e Integer) 'Integer)]
      [(? boolean?)
       (values `(has-type ,e Boolean) 'Boolean)]
      [(? symbol?)
       (let ([t (lookup e env)])
         (values `(has-type ,e ,t) t))]
      ['(void) (values '(has-type (void) Void) 'Void)]
      ['(read) (values '(has-type (read) Integer) 'Integer)]
      [`(vector ,(app (typecheck env) e* t*) ...)
       (let ([t `(Vector ,@t*)])
         (values `(has-type (vector ,@e*) ,t) t))]
      [`(vector-ref ,(app (typecheck env) e t) ,i)
       (match t
         [`(Vector ,ts ...)
          (unless (and (exact-nonnegative-integer? i)
                       (i . < . (length ts)))
                  (error 'typecheck "invalid index ~a" i))
          (let ([t (list-ref ts i)])
            (values `(has-type (vector-ref ,e (has-type ,i Integer)) ,t)
                    t))]
         [else (error "expected a vector in vector-ref, not" t)])]
      [`(vector-set! ,(app (typecheck env) e-vec^ t-vec) ,i
                     ,(app (typecheck env) e-arg^ t-arg))
       (match t-vec
         [`(Vector ,ts ...)
          (unless (and (exact-nonnegative-integer? i)
                       (i . < . (length ts)))
            (error 'typecheck "invalid index ~a" i))
          (unless (equal? (list-ref ts i) t-arg)
            (error 'typecheck "type mismatch in vector-set! ~a ~a"
                   (list-ref ts i) t-arg))
          (values `(has-type (vector-set! ,e-vec^
                                          (has-type ,i Integer)
                                          ,e-arg^) Void) 'Void)]
         [else (error 'typecheck
                      "expected a vector in vector-set!, not ~a" t-vec)])]
      [`(eq? ,(app (typecheck env) e1 t1)
              ,(app (typecheck env) e2 t2))
       (match* (t1 t2)
         [(`(Vector ,ts1 ...) `(Vector ,ts2 ...))
          (values `(has-type (eq? ,e1 ,e2) Boolean) 'Boolean)]
         [(other wise)
          (if (eq? t1 t2)
            (values `(has-type (eq? ,e1 ,e2) Boolean) 'Boolean)
            (error 'typecheck "'eq?' arg types not matching in ~s" e))])]
      [`(let ([,x ,(app (typecheck env) e₁ t₁)]) ,body)
        (let-values ([(e₂ t₂) ((typecheck `((,x . ,t₁) . ,env)) body)])
          (values `(has-type (let ([,x ,e₁]) ,e₂) ,t₂) t₂))]
      [`(- ,(app (typecheck env) e₀ t₀))
        (match t₀
          ['Integer (values `(has-type (- ,e₀) Integer) 'Integer)]
          [else (error 'typecheck "'-' expects an Integer in ~s" e)])]
      [`(not ,(app (typecheck env) e₀ t₀))
        (match t₀
          ['Boolean (values `(has-type (- ,e₀) Boolean) 'Boolean)]
          [else (error 'typecheck "'not' expects a Boolean in ~s" e)])]
      [`(if ,(app (typecheck env) e* t*) ...)
        (match t*
          [`(Integer ,then-else ...) (error 'typecheck "'if' expects a Boolean in ~s" e)]
          [`(Boolean ,thenT ,elseT)
            (if (eq? thenT elseT)
              (values `(has-type (if ,@e*) ,thenT) thenT)
              (error 'typecheck "'if' clause types not matching in ~s" e))])]
      [`(+ ,(app (typecheck env) e* t*) ...)
        (match t*
          ['(Integer Integer) (values `(has-type (+ ,@e*) Integer) 'Integer)]
          [else (error 'typecheck "'+' expects two Integers in ~s" e)])]
      [`(and ,(app (typecheck env) e* t*) ...)
        (match t*
          ['(Boolean Boolean) (values `(has-type (and ,@e*) Boolean) 'Boolean)]
          [else (error 'typecheck "'and' expects two Booleans in ~s" e)])]
      [`(,cmp ,(app (typecheck env) e* t*) ...)
        (match t*
          ['(Integer Integer) (values `(has-type (and ,@e*) Boolean) 'Boolean)]
          [else (error 'typecheck (~a "'" cmp "' expects two Integers in ~s" e))])]
      )))

(define (typecheck-R3 p)
  ((typecheck '()) p))