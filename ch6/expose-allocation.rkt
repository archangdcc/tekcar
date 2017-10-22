#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide expose-allocation-R4)


(define (vec-alloc es t v n)
  (match es
    ['()
     (let ([b (* 8 (+ 1 n))]
           [collectret (gen-sym 'collectret)])
       (values
         (lambda (tail)
           `(has-type
              (let ([,collectret
                      (has-type
                        (if (has-type
                              (< (has-type
                                   (+ (has-type (global-value free_ptr) Integer)
                                      (has-type ,b Integer))
                                      Integer)
                                 (has-type (global-value fromspace_end) Integer))
                              Boolean)
                          (has-type (void) Void)
                          (has-type (collect ,b) Void))
                        Void)])
                (has-type
                  (let ([,v (has-type
                             (allocate ,n ,t)
                             ,t)])
                    ,tail)
                  ,t))
              ,t))
         `(has-type ,v ,t)))]
    [`(,e . ,es)
      (let-values ([(main tail) (vec-alloc es t v (+ 1 n))])
        (let ([vecinit (gen-sym 'vecinit)]
              [initret (gen-sym 'initret)])
          (values
            (lambda(tail)
              `(has-type
                 (let ([,vecinit ,(exalloc e)])
                   ,(main tail))
                 ,t))
            `(has-type
               (let
                 ([,initret
                    (has-type
                      (vector-set!
                        (has-type ,v ,t)
                        (has-type ,n Integer)
                        (has-type ,vecinit ,(caddr e)))
                      Void)])
                 ,tail)
               ,t))))]))

(define (exalloc e)
  (match e
    [`(has-type (vector . ,es) ,t)
      (let ([v (gen-sym 'alloc)])
        (let-values ([(main tail) (vec-alloc es t v 0)])
          (main tail)))]
    [`(has-type ,e ,t)
     `(has-type ,(exalloc e) ,t)]
    [`(let ([,x ,e]) ,body)
     `(let ([,x ,(exalloc e)]) ,(exalloc body))]
    [`(define (,fn ,args ...) : ,t ,e)
     `(define (,fn ,@args) : ,t ,(exalloc e))]
    [`(program ,type ,ds ... ,e)
     `(program ,type ,@(map exalloc ds) ,(exalloc e))]
    [`(,es ...)
     `(,@(map exalloc es))]
    [_ e]))

(define (expose-allocation-R4 e)
  (exalloc e))
