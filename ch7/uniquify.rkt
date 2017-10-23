#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide uniquify-R5)

(define (addf def alist)
  (match-let
    ([`(define (,fn ,arg ...) : ,t ,e) def])
    (let ([gn (gen-sym fn)])
      `((,fn . ,gn) . ,alist))))

(define (adda arg alist)
  (match-let
    ([`(,v : ,t) arg])
    (let ([w (gen-sym v)])
      `((,v . ,w) . ,alist))))

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
      [`(,x : ,t)
       `(,(lookup x alist) : ,t)]
      [`(let ([,x ,e]) ,body)
        (let ([y (gen-sym x)])
          `(let ([,y ,((uniq alist) e)])
             ,((uniq `((,x . ,y) . ,alist)) body)))]
      [`(define (,fn ,args ...) : ,t ,e)
        (let ([alist (foldl adda alist args)])
          `(define
             (,((uniq alist) fn) ,@(map (uniq alist) args)) : ,t
             ,((uniq alist) e)))]
      [`(lambda: ,args : ,t ,e)
        (let ([alist (foldl adda alist args)])
          `(lambda: ,(map (uniq alist) args) : ,t ,((uniq alist) e)))]
      [`(program ,type ,ds ... ,e)
        (let ([alist (foldl addf alist ds)])
          `(program ,type ,@(map (uniq alist) ds) ,((uniq alist) e)))]
      [`(,es ...) `(,@(map (uniq alist) es))]
      )))

(define (uniquify-R5 e)
  (begin
    (init-sym)
    ((uniq '()) e)))
