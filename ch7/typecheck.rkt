#lang racket

(require "../utilities.rkt")

(provide typecheck-R5)

(define (fenv def)
  (match-let
    ([`(define (,fn [,vs : ,ts] ...) : ,t ,body) def])
    `(,fn . ( ,@ts -> ,t))))

(define (typecheck env)
  (lambda (e)
    (match e
      [`(program ,ds ... ,e)
        (let*
          ([env (map fenv ds)])
         ((typecheck env) e)
        `(program ,@(map (typecheck env) ds) ,e))]
      [`(define (,fn ,args ...) : ,t ,e)
        (match-let
          ([`([,vs : ,ts] ...) args])
          (let
            ([t* ((typecheck (append (map cons vs ts) env)) e)])
            (if (equal? t t*)
              `(define (,fn ,@args) : ,t ,e)
              (error 'typecheck "function ~a type mismatch" fn))))]
      [(? fixnum?)  'Integer]
      [(? boolean?) 'Boolean]
      [(? symbol?) (lookup e env)]
      ['(void) 'Void]
      [`(read) 'Integer]
      [`(vector ,(app (typecheck env) t) ...)
       `(Vector ,@t)]
      [`(vector-ref ,(app (typecheck env) t) ,i)
        (match t
          [`(Vector ,ts ...)
            (unless (and (exact-nonnegative-integer? i)
                         (i . < . (length ts)))
              (error 'typecheck "invalid index ~a" i))
            (list-ref ts i)]
         [else (error "expected a vector in vector-ref, not" t)])]
      [`(vector-set! ,(app (typecheck env) t-vec) ,i
                     ,(app (typecheck env) t-arg))
        (match t-vec
          [`(Vector ,ts ...)
            (unless (and (exact-nonnegative-integer? i)
                         (i . < . (length ts)))
              (error 'typecheck "invalid index ~a" i))
            (unless (equal? (list-ref ts i) t-arg)
              (error 'typecheck "type mismatch in vector-set! ~a ~a"
                     (list-ref ts i) t-arg))
            'Void]
          [else (error 'typecheck
                       "expected a vector in vector-set!, not ~a" t-vec)])]
      [`(let ([,x ,(app (typecheck env) T)]) ,body)
        ((typecheck `((,x . ,T) . ,env)) body)]
      [`(lambda: ([,xs : ,Ts] ...) : ,rT ,body)
        (define new-env (append (map cons xs Ts) env))
        (define bodyT ((typecheck new-env) body))
        (cond [(equal? rT bodyT)
               `(,@Ts -> ,rT)]
              [else
                (error "mismatch in return type" bodyT rT)])]
      [`(- ,(app (typecheck env) T))
        (match T
          ['Integer 'Integer]
          [else (error 'typecheck "'-' expects an Integer in ~s" e)])]
      [`(not ,(app (typecheck env) T))
        (match T
          ['Boolean 'Boolean]
          [else (error 'typecheck "'not' expects a Boolean in ~s" e)])]
      [`(if ,@(app (lambda (es)
                    (map (typecheck env) es)) T))
        (match T
          [`(Integer ,then-else ...) (error 'typecheck "'if' expects a Boolean in ~s" e)]
          [`(Boolean ,thenT ,elseT)
            (if (equal? thenT elseT) thenT (error 'typecheck "'if' clause types not matching in ~s" e))])]
      [`(+ ,@(app (lambda (es)
                    (map (typecheck env) es)) T))
        (match T
          ['(Integer Integer) 'Integer]
          [else (error 'typecheck "'+' expects two Integers in ~s" e)])]
      [`(and ,@(app (lambda (es)
                    (map (typecheck env) es)) T))
        (match T
          ['(Boolean Boolean) 'Boolean]
          [else (error 'typecheck "'and' expects two Booleans in ~s" e)])]
      [`(eq? ,@(app (lambda (es)
                      (map (typecheck env) es)) T))
        (match T
          [`(,T₁ ,T₂)
            (if (eq? T₁ T₂) 'Boolean (error 'typecheck "'eq?' arg types not matching in ~s" e))])]
      [`(,cmp ,(app (typecheck env) t*) ...)
        #:when (set-member? (set '< '> '<= '>=) cmp)
        (match t*
          ['(Integer Integer) 'Boolean]
          [else (error 'typecheck (~a "'" cmp "' expects two Integers in ~s" e))])]
      [`(,(app (typecheck env) tf) ,(app (typecheck env) t*) ...)
        (match tf
          [`(,ta ... -> ,tf)
            (if (equal? ta t*) tf
              (error 'typecheck "arguments expect ~s not ~s in ~s" ta t* e))]
          [_ (error 'typecheck "expects a function in ~s" e)])]
      )))

(define (typecheck-R5 p)
  ((typecheck '()) p))

;(typecheck-R5
;'(program (let ((x 42)) (let ((f (lambda () x))) (f))))
;)

(typecheck-R5
'(program (let ((x 42)) (let ((f (lambda: () : Integer x))) (f))))
)
