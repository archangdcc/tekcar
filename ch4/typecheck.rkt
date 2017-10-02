#lang racket

(require "../utilities.rkt")

(provide typecheck-R2)

(define (typecheck env)
  (lambda (e)
    (match e
      [`(program ,body)
       `(program (type ,((typecheck '()) body)) ,body)]
      [(? fixnum?)  'Integer]
      [(? boolean?) 'Boolean]
      [(? symbol?)
       (lookup e env)]
      [`(read) 'Integer]
      [`(let ([,x ,(app (typecheck env) T)]) ,body)
        ((typecheck `((,x . ,T) . ,env)) body)]
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
            (if (eq? thenT elseT) thenT (error 'typecheck "'if' clause types not matching in ~s" e))])]
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
      [`(,cmp ,@(app (lambda (es)
                      (map (typecheck env) es)) T))
        (match T
          ['(Integer Integer) 'Boolean]
          [else (error 'typecheck (~a "'" cmp "' expects two Integers in ~s" e))])]
      )))

(define (typecheck-R2 p)
  ((typecheck '()) p))
