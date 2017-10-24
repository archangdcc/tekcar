#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide convert-to-closures)

(define (assign-fvs e t fvs n)
  (cond
    [(null? fvs) e]
    [else
      `(has-type
         (let
           ([,(caar fvs)
              (has-type
                (vector-ref
                  (has-type clos (Vector _))
                  (has-type ,n Integer))
                ,(cdar fvs))])
         ,(assign-fvs e t (cdr fvs) (+ 1 n)))
         ,t)]))

(define (occur-free vs)
  (lambda (e)
    (match e
      [`(has-type ,e ,t)
        #:when (and (symbol? e) (not (member e vs)))
        (set `(,e . ,t))]
      [`(has-type ,e ,t) ((occur-free vs) e)]
      [`(let ([,x ,e]) ,b)
        (set-union ((occur-free vs) e) ((occur-free (cons x vs)) b))]
      [`(lambda: ([,us : ,ts] ...) : ,t ,e)
        ((occur-free (append us vs)) e)]
      [`(,es ...)
        (foldl set-union (set) (map (occur-free vs) es))]
      [_ (set)])))

(define (convert-to-closures e)
  (match e
    [`(has-type (lambda: ,args : ,t ,e) ,tl)
      (match-let ([`([,vs : ,ts] ...) args])
        (let ([fvs (set->list ((occur-free vs) e))]
              [fn (gen-sym 'lambda)])
          (let-values ([(e clos) (convert-to-closures e)])
            (values
              `(has-type
                 (vector
                   (has-type (function-ref ,fn) ((Vector _) ,@ts -> ,t))
                   ,@(map (lambda (fv) `(has-type ,(car fv) ,(cdr fv))) fvs))
                 (Vector _))
              `((define
                  (,fn [clos : (Vector _)] ,@args) : ,t
                  ,(assign-fvs e t fvs 1))
                ,@clos)))))]
    [`(has-type (app ,f ,es ...) ,t)
      (let ([clo (gen-sym 'clo)])
        (let-values
          ([(f clof) (convert-to-closures f)]
           [(es clos) (map2 convert-to-closures es)])
          (values
            `(has-type
               (let ([,clo ,f])
                 (has-type
                   (app
                     (has-type
                       (vector-ref
                         (has-type ,clo (Vector _))
                         (has-type 0 Integer))
                       ((Vector _) ... -> ,t))
                     (has-type ,clo (Vector _)) ,@es)
                 ,t)) ,t)
            `(,@clof ,@(append* clos))
            )))]
    [`(has-type (function-ref ,f) ,t)
      (values
        `(has-type
           (vector
             (has-type
               (function-ref ,f)
               ,t))
           (Vector ,t))
        '())]
    [`(has-type ,e ,t)
      (let-values
        ([(e clos) (convert-to-closures e)])
        (values
          `(has-type ,e ,t)
          clos))]
    [(? integer?) (values e '())]
    [(? boolean?) (values e '())]
    [(? symbol?) (values e '())]
    [`(let ([,x ,e]) ,b)
      (let-values
        ([(e cloe) (convert-to-closures e)]
         [(b clob) (convert-to-closures b)])
        (values
          `(let ([,x ,e]) ,b)
          `(,@cloe ,@clob)))]
    [`(define (,fn ,args ...) : ,t ,e)
      (let-values ([(e clos) (convert-to-closures e)])
        (values
          `(define (,fn [clos : (Vector _)] ,@args) : ,t ,e)
          clos))]
    [`(program ,type ,ds ... ,e)
      (let-values
        ([(ds clods) (map2 convert-to-closures ds)]
         [(e cloe) (convert-to-closures e)])
        `(program ,type ,@(append* clods) ,@ds ,@cloe ,e))]
    [`(,op ,es ...)
      #:when (set-member? R4-ops op)
      (let-values
        ([(es clos) (map2 convert-to-closures es)])
        (values
          `(,op ,@es)
          (append* clos)))]
    [`(,es ...)
      (let-values
        ([(es clos) (map2 convert-to-closures es)])
        (values es (append* clos)))]))
