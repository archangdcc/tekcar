#lang racket

(require "../utilities.rkt")
(provide uniquify)

(define (uniquify alist)
  (lambda (e)
    (match e
      [(? symbol?) (lookup e alist)]
      [(? integer?) e]
      [`(let ([,x ,e]) ,body)
        (let ([y (gensym)])
          `(let ([,y ,((uniquify alist) e)])
             ,((uniquify `((,x . ,y) . ,alist)) body)))]
      [`(program ,e) `(program ,((uniquify alist) e))]
      [`(,op ,es ...) `(,op ,@(map (uniquify alist) es))]
      )))
