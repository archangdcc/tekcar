#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide reveal-functions-R6)

(define (addf def fns)
  (match-let
    ([`(define (,fn ,arg ...) : ,t ,e) def])
    (cons fn fns)))

(define (reveal-functions fns)
  (lambda (e)
    (match e
      [`(has-type ,e ,t)
       `(has-type ,((reveal-functions fns) e) ,t)]
      [(? integer?) e]
      [(? boolean?) e]
      [(? symbol?)
       #:when (member e fns)
       `(function-ref ,e)]
      [(? symbol?) e]
      [`(let ([,x ,e]) ,body)
       `(let ([,x ,((reveal-functions fns) e)])
          ,((reveal-functions fns) body))]
      [`(define (,fn ,args ...) : ,t ,e)
       `(define (,fn ,@args) : ,t ,((reveal-functions fns) e))]
      [`(lambda: ,args : ,t ,e)
       `(lambda: ,args : ,t ,((reveal-functions fns) e))]
      [`(program ,type ,ds ... ,e)
        (let ([fns (foldr addf fns ds)])
          `(program ,type
            ,@(map (reveal-functions fns) ds)
            ,((reveal-functions fns) e)))]
      [`(inject ,e ,t)
        `(inject ,((reveal-functions fns) e) ,t)]
      [`(project ,e ,t)
        `(project ,((reveal-functions fns) e) ,t)]
      [`(,op ,es ...)
        #:when (set-member? R4-ops op)
        `(,op ,@(map (reveal-functions fns) es))]
      [`(,es ...)
       `(app ,@(map (reveal-functions fns) es))])))

(define (reveal-functions-R6 e)
  ((reveal-functions '()) e))
