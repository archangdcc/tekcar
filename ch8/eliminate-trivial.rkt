#lang racket

(require "../global.rkt")
(require "../utilities.rkt")

(provide eliminate-trivial)

(define (addf def)
  (match def
    [`(define (,fn [,vs : ,ts] ...) : ,tf ,e)
     `(,fn . (,@ts -> ,tf))]))

(define (type-eq? t₁ t₂)
  (match* (t₁ t₂)
    [(`(Vector ,ts ...) `(Vectorof Any)) #t]
    [(`(Vectorof Any) `(Vector ,ts ...)) #t]
    [(other wise) (equal? t₁ t₂)]))

(define (elim fns)
  (lambda (e)
    (match e
      [`(project (inject ,e ,t₁) ,t₂)
        #:when (type-eq? t₁ t₂)
        e]
      [`(program ,ds ... ,e)
        (let* ([fns (map addf ds)]
               [e ((elim fns) e)])
          `(program
             ,@(map (elim fns) ds)
             ,e))]
      ;[`(define (,fn ,vars ...) : ,tf ,e)
      ; `(define (,fn ,@vars) : ,tf ,((elim fns) e))]
      ;[`(lambda: ,vars : ,t ,e)
      ; `(lambda: ,vars : ,t ,((elim fns) e))]
      ;[`(let ([,v ,e]) ,b)
      ; `(let ([,v ,((elim fns) e)]) ,((elim fns) b))]
      [`(,es ...)
        (map (elim fns) es)]
      [_ e])))

(define (eliminate-trivial e)
  ((elim '()) e))
