#lang racket

(require "../global.rkt")
(require "../utilities.rkt")

(provide cast-insert)

(define (append-any v) `(,v : Any))

(define (any v) 'Any)

(define (addf def)
  (match def
    [`(define (,fn ,arg ...) ,e)
     `(,fn . (,@(map any arg) -> Any))]))

(define (cast fns)
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
        (let* ([fns (map addf ds)]
               [e ((cast fns) e)])
          `(program
             ,@(map (cast fns) ds)
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
          : Any ,((cast fns) e))]
      [`(lambda ,vars ,e)
       `(inject
          (lambda: ,(map append-any vars)
            : Any ,((cast fns) e))
          (,@(map any vars) -> Any))]
      [`(let ([,v ,e]) ,b)
       `(let ([,v ,((cast fns) e)]) ,((cast fns) b))]
      [`(read) `(inject (read) Integer)]
      [`(void) `(inject (void) Void)]
      [`(vector ,es ...)
       `(inject
          (vector ,@(map (cast fns) es))
          (Vector ,@(map any es)))]
      [`(vector-ref ,e₁ ,e₂)
       `(vector-ref
          (project ,((cast fns) e₁) (Vectorof Any))
          (project ,((cast fns) e₂) Integer))]
      [`(vector-set! ,e₁ ,e₂ ,e₃)
       `(inject
          (vector-set!
            (project ,((cast fns) e₁) (Vectorof Any))
            (project ,((cast fns) e₂) Integer)
            ,((cast fns) e₃))
          Void)]
      [`(- ,e)
       `(inject
          (- (project ,((cast fns) e) Integer))
          Integer)]
      [`(+ ,e₁ ,e₂)
       `(inject
          (+ (project ,((cast fns) e₁) Integer)
             (project ,((cast fns) e₂) Integer))
          Integer)]
      [`(not ,e)
       `(if (eq? ,((cast fns) e) (inject #f Boolean))
          (inject #t Boolean)
          (inject #f Boolean))]
      [`(and ,e₁ ,e₂)
       `(let ([tmp ,((cast fns) e₁)])
          (if (eq? tmp (inject #f Boolean))
            tmp ,((cast fns) e₂)))]
      [`(eq? ,e₁ ,e₂)
        `(inject
           (eq?
             ,((cast fns) e₁)
             ,((cast fns) e₂))
           Boolean)]
      [`(,cmp ,e₁ ,e₂)
        #:when (set-member? (set '< '> '<= '>=) cmp)
       `(inject
          (,cmp (project ,((cast fns) e₁) Integer)
                (project ,((cast fns) e₂) Integer))
          Boolean)]
      [`(if ,c ,e₁ ,e₂)
       `(if (eq? ,((cast fns) c) (inject #f Boolean))
          ,((cast fns) e₂)
          ,((cast fns) e₁))]
      [`(,f ,es ...)
       `((project ,((cast fns) f) (,@(map any es) -> Any))
         ,@(map (cast fns) es))]
      [_ e])))

(define (cast-insert e)
  ((cast '()) e))
