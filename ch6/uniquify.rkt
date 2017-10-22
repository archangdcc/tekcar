#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide uniquify-R4)

(define (uniq alist)
  (lambda (e)
    (match e
      [`(has-type ,e ,t)
       `(has-type ,((uniq alist) e) ,t)]
      [(? symbol?) (lookup e alist e)]
      [(? integer?) e]
      [(? boolean?) e]
      ['(read) e]
      ['(void) e]
      [`(let ([,x ,e]) ,body)
        (let ([y (gen-sym x)])
          `(let ([,y ,((uniq alist) e)])
             ,((uniq `((,x . ,y) . ,alist)) body)))]
      [`(define (,fn ,args ...) : ,t ,e)
       `(define (,fn ,@args) : ,t ,((uniq alist) e))]
      [`(program ,type ,ds ... ,e)
       `(program ,type ,@(map (uniq alist) ds) ,((uniq alist) e))]
      [`(,es ...) `(,@(map (uniq alist) es))]
      )))

(define (uniquify-R4 e)
  (begin
    (init-sym)
    ((uniq '()) e)))
