#lang racket

(require "../global.rkt")
(require "../utilities.rkt")

(provide entype)

(define (append-any v) `(,v : Any))

(define (any v) 'Any)

(define (addf def fns)
  (match-let
    ([`(define (,fn ,arg ...) ,e) def])
    (cons `(,fn . (,@(map any arg) -> Any)) fns)))

(define (ent fns)
  (lambda (e)
    (match e
      [(? boolean?)
       `(inject ,e Boolean)]
      [(? fixnum?)
       `(inject ,e Integer)]
      [(? symbol?)
       (let ([t (lookup e fns #f)])
         (if t `(inject ,e ,t) e))]
      [`(program ,ds ... ,e)
        (let* ([fns (foldr addf fns ds)]
               [e ((ent fns) e)])
          `(program
             ,@(map (ent fns) ds)
             ,e))]
            ; (let ([ans ,e])
            ;   (if (boolean? ans)
            ;     (project ans Boolean)
            ;   (if (integer? ans)
            ;     (project ans Integer)
            ;   (if (vector? ans)
            ;     (project ans (Vectorof Any))
            ;   (if (void? ans)
            ;     (project ans Void)
            ;   (if (procedure? ans)
            ;     (project ans (Any -> Any))
            ;     ))))))))]
      [`(define (,fn ,vars ...) ,e)
       `(define (,fn ,@(map append-any vars))
          : Any ,((ent fns) e))]
      [`(lambda ,vars ,e)
       `(inject
          (lambda: ,(map append-any vars)
            : Any ,((ent fns) e))
          (,@(map any vars) -> Any))]
      [`(let ([,v ,e]) ,b)
       `(let ([,v ,((ent fns) e)]) ,((ent fns) b))]
      [`(read) `(inject (read) Integer)]
      [`(void) `(inject (void) Void)]
      [`(vector ,es ...)
       `(inject
          (vector ,@(map (ent fns) es))
          (Vectorof Any))]
      [`(vector-ref ,e₁ ,e₂)
       `(vector-ref
          (project ,((ent fns) e₁) (Vectorof Any))
          (project ,((ent fns) e₂) Integer))]
      [`(vector-set! ,e₁ ,e₂ ,e₃)
       `(inject
          (vector-set!
            (project ,((ent fns) e₁) (Vectorof Any))
            (project ,((ent fns) e₂) Integer)
            ,((ent fns) e₃))
          Void)]
      [`(- ,e)
       `(inject
          (- (project ,((ent fns) e) Integer))
          Integer)]
      [`(+ ,e₁ ,e₂)
       `(inject
          (+ (project ,((ent fns) e₁) Integer)
             (project ,((ent fns) e₂) Integer))
          Integer)]
      [`(not ,e)
       `(if (eq? ,((ent fns) e) (inject #f Boolean))
          (inject #t Boolean)
          (inject #f Boolean))]
      [`(and ,e₁ ,e₂)
       `(let ([tmp ,((ent fns) e₁)])
          (if (eq? tmp (inject #f Boolean))
            tmp ,((ent fns) e₂)))]
      [`(eq? ,e₁ ,e₂)
        `(inject
           (eq?
             ,((ent fns) e₁)
             ,((ent fns) e₂))
           Boolean)]
      [`(,cmp ,e₁ ,e₂)
        #:when (set-member? (set '< '> '<= '>=) cmp)
       `(inject
          (,cmp (project ,((ent fns) e₁) Integer)
                (project ,((ent fns) e₂) Integer))
          Boolean)]
      [`(if ,c ,e₁ ,e₂)
       `(if (eq? ,((ent fns) c) (inject #f Boolean))
          ,((ent fns) e₂)
          ,((ent fns) e₁))]
      [`(,f ,es ...)
       `((project ,((ent fns) f) (,@(map any es) -> Any))
         ,@(map (ent fns) es))]
      [_ e])))

(define (entype e)
  ((ent '()) e))
