#lang racket

(require "../global.rkt")

(provide handler-to-callcc)

(define (htc handler)
  (lambda (e)
    (match e
      [(? boolean?) e]
      [(? fixnum?) e]
      [(? symbol?) e]
      [`(with-handlers ([,test ,h]) ,b)
        (let ([cc (gen-sym 'cc)])
        `(call/cc
           (lambda (,cc)
             (let ([,handler (lambda (e) (if (,test e) (,cc (,h e)) (,handler e)))])
               ,((htc handler) b)))))]
      [`(raise ,e)
        `(,handler ,e)]
      [`(define (,fn ,args ...) ,e)
       `(define (,fn ,@args) ,((htc handler) e))]
      [`(program ,ds ... ,e)
       `(program
          (define (,handler e)
            (void))
          ,@(map (htc handler) ds)
          ,((htc handler) e))]
      [`(lambda ,args ,e)
       `(lambda (,@args)
          ,((htc handler) e))]
      [`(let ([,x ,e]) ,b)
       `(let ([,x ,((htc handler) e)]) ,((htc handler) b))]
      [`(,args ...)
       `(,@(map (htc handler) args))])))

(define handler-to-callcc
  (begin
    (init-sym)
    (let ([handler (gen-sym 'handler)])
      (htc handler))))
