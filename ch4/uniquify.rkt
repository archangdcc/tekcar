#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide uniquify-R2)

(define (uniq alist)
  (lambda (e)
    (match e
      [(? symbol?) (lookup e alist)]
      [(? integer?) e]
      [(? boolean?) e]
      ['(read) e]
      [`(let ([,x ,e]) ,body)
        (let ([y (gen-sym x)])
          `(let ([,y ,((uniq alist) e)])
             ,((uniq `((,x . ,y) . ,alist)) body)))]
      [`(program ,type ,e) `(program ,type ,((uniq alist) e))]
      [`(,op ,es ...) `(,op ,@(map (uniq alist) es))]
      )))

(define (uniquify-R2 e)
  (begin
    (init-sym)
    ((uniq '()) e)))
