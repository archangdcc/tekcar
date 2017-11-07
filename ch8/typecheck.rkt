#lang racket

(require "../utilities.rkt")

(provide typecheck-R6)

(define (has-type e t)
  (values
    `(has-type ,e ,t) t))

(define (fenv def)
  (match-let
    ([`(define (,fn [,vs : ,ts] ...) : ,t ,body) def])
    `(,fn . ( ,@ts -> ,t))))

(define (typecheck env)
  (lambda (e)
    (match e
      [`(inject ,e ,t)
        (let-values ([(e* t*) ((typecheck env) e)])
          (cond
            [(equal? t* t)
             (has-type `(inject ,e* ,t) 'Any)]
            [else
              (error 'typecheck "inject expected ~a to have type ~a" e t)]))]
      [`(project ,e ,t)
        (let-values ([(e* t*) ((typecheck env) e)])
          (cond
            [(equal? t* 'Any)
             (has-type `(project ,e* ,t) t)]
            [else
              (error 'typecheck "project expected ~a to have type Any" e)]))]
      [`(program ,ds ... ,e)
        (let
          ([env (map fenv ds)])
          (let*-values
            ([(e* t*) ((typecheck env) e)])
            `(program (type ,t*) ,@(map (typecheck env) ds) ,e*)))]
      [`(define (,fn ,args ...) : ,t ,e)
        (match-let
          ([`([,vs : ,ts] ...) args])
          (let-values
            ([(e* t*) ((typecheck (append (map cons vs ts) env)) e)])
            (if (equal? t t*)
              `(define (,fn ,@args) : ,t ,e*)
              (error 'typecheck "function ~a type mismatch" fn))))]
      [(? fixnum?) (has-type e 'Integer)]
      [(? boolean?) (has-type e 'Boolean)]
      [(? symbol?)
       (let ([t (lookup e env)])
         (has-type e t))]
      ['(void) (has-type e 'Void)]
      ['(read) (has-type e 'Integer)]
      [`(vector ,(app (typecheck env) e* t*) ...)
        (let ([t `(Vector ,@t*)])
          (has-type `(vector ,@e*) t))]
      [`(vector-ref ,(app (typecheck env) ve vt) ,(app (typecheck env) ie it))
        (match vt
          [`(Vectorof ,t)
            (has-type `(vector-ref ,ve ,ie) t)]
          [else (error "expected a vector in vector-ref, not" vt)])]
      [`(vector-set! ,(app (typecheck env) e-vec t-vec)
                     ,(app (typecheck env) e-idx t-idx)
                     ,(app (typecheck env) e-arg t-arg))
        (match t-vec
          [`(Vectorof ,t)
            (has-type `(vector-set! ,e-vec ,e-idx ,e-arg) 'Void)]
          [else (error 'typecheck
                       "expected a vector in vector-set!, not ~a" t-vec)])]
      [`(eq? ,(app (typecheck env) e1 t1)
             ,(app (typecheck env) e2 t2))
        (match* (t1 t2)
          [(`(Vector ,ts1 ...) `(Vector ,ts2 ...))
           (has-type `(eq? ,e1 ,e2) 'Boolean)]
          [(other wise)
           (if (eq? t1 t2)
             (has-type `(eq? ,e1 ,e2) 'Boolean)
             (error 'typecheck "'eq?' arg types not matching in ~s" e))])]
      [`(let ([,x ,(app (typecheck env) e₁ t₁)]) ,body)
        (let-values ([(e₂ t₂) ((typecheck `((,x . ,t₁) . ,env)) body)])
          (has-type `(let ([,x ,e₁]) ,e₂) t₂))]
      [`(lambda: ,args : ,tl ,e)
        (match-let
          ([`([,vs : ,ts] ...) args])
          (let-values
            ([(e* tb)
              ((typecheck (append (map cons vs ts) env)) e)])
            (if (equal? tl tb)
              (has-type `(lambda: ,args : ,tl ,e*) `(,@ts -> ,tl))
              (error "mismatch in return type" tb tl))))]
      [`(- ,(app (typecheck env) e₀ t₀))
        (match t₀
          ['Integer (has-type `(- ,e₀) 'Integer)]
          [else (error 'typecheck "'-' expects an Integer in ~s" e)])]
      [`(not ,(app (typecheck env) e₀ t₀))
        (match t₀
          ['Boolean (has-type `(- ,e₀) 'Boolean)]
          [else (error 'typecheck "'not' expects a Boolean in ~s" e)])]
      [`(if ,(app (typecheck env) e* t*) ...)
        (match t*
          [`(Integer ,then-else ...) (error 'typecheck "'if' expects a Boolean in ~s" e)]
          [`(Boolean ,thenT ,elseT)
            (if (equal? thenT elseT)
              (has-type `(if ,@e*) thenT)
              (error 'typecheck "'if' clause types not matching in ~s" e))])]
      [`(+ ,(app (typecheck env) e* t*) ...)
        (match t*
          ['(Integer Integer) (has-type `(+ ,@e*) 'Integer)]
          [else (error 'typecheck "'+' expects two Integers in ~s" e)])]
      [`(and ,(app (typecheck env) e* t*) ...)
        (match t*
          ['(Boolean Boolean) (has-type `(and ,@e*) 'Boolean)]
          [else (error 'typecheck "'and' expects two Booleans in ~s" e)])]
      [`(,cmp ,(app (typecheck env) e* t*) ...)
        #:when (set-member? (set '< '> '<= '>=) cmp)
        (match t*
          ['(Integer Integer) (has-type `(and ,@e*) 'Boolean)]
          [else (error 'typecheck (~a "'" cmp "' expects two Integers in ~s" e))])]
      [`(,(app (typecheck env) f tf) ,(app (typecheck env) e* t*) ...)
        (match tf
          [`(,ta ... -> ,tf)
            (if (equal? ta t*)
              (has-type `(,f ,@e*) tf)
              (error 'typecheck "arguments expect ~s not ~s in ~s" ta t* e))]
          [_ (error 'typecheck "expects a function in ~s" e)])]
      )))

(define (typecheck-R6 p)
  ((typecheck '()) p))
