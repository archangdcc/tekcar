#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide uniquify)

(define (uniq alist)
  (lambda (e)
    (match e
      [(? symbol?) (lookup e alist)]
      [(? integer?) e]
      ['(read) e]
      [`(let ([,x ,e]) ,body)
        (let ([y (gen-sym x)])
          `(let ([,y ,((uniq alist) e)])
             ,((uniq `((,x . ,y) . ,alist)) body)))]
      [`(program ,e) `(program ,((uniq alist) e))]
      [`(,op ,es ...) `(,op ,@(map (uniq alist) es))]
      )))

(define (uniquify e)
  (init-sym)
  ((uniq '()) e))
