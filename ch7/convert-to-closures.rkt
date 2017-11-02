#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide convert-to-closures)

(define (assign-args args vs e t)
  (cond
    [(null? args) e]
    [else
      `(has-type
         (let
           ([,(car args) ,(car vs)])
           ,(assign-args (cdr args) (cdr vs) e t))
         ,t)]))

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

(define (function-to-closure-type t)
  (if (and (pair? t) (member '-> t))
    `(Vector _) t))

(define (convert-to-closures e)
  (match e
    [`(has-type (lambda: ([,vs : ,ts] ...) : ,t ,e) ,tl)
      (let-values ([(e clos) (convert-to-closures e)])
        (let* ([fvs (set->list ((occur-free vs) e))]
               [fvts (map function-to-closure-type (map cdr fvs))]
               [ts* (map function-to-closure-type ts)]
               [t* (caddr e)]
               [tl* `((Vector ,tl ,@fvts) ,@ts* -> ,t*)]
               [tc `(Vector ,tl* ,@fvts)]
               [fn (gen-sym 'lambda)])
          (values
            `(has-type
               (vector
                 (has-type (function-ref ,fn) ,tl*)
                 ,@(map (lambda (fv fvt) `(has-type ,(car fv) ,fvt)) fvs fvts))
               ,tc)
            `((define
                (,fn [clos : ,tc] ,@(map (lambda (v t) `[,v : ,t]) vs ts*)) : ,t*
                ,(assign-fvs e t* fvs 1))
              ,@clos))))]
    [`(has-type (app (has-type (function-ref ,f) ,tf) ,es ...) ,t)
      (let-values ([(es clos) (map2 convert-to-closures es)])
        (let* ([f* (string->symbol (format "~s.direct" f))]
               [t* (function-to-closure-type t)]
               [tf* `(,@(map caddr es) -> ,t*)])
          (values
            `(has-type (app (has-type (function-ref ,f*) ,tf*) ,@es) ,t*)
            (append* clos))))]
    [`(has-type (app (has-type (lambda: ([,vs : ,ts] ...) : ,t ,e) ,tl) ,es ...) ,t)
      (let-values ([(e clo) (convert-to-closures e)]
                   [(es clos) (map2 convert-to-closures es)])
        (values (assign-args vs es e (caddr e)) `(,@clo ,@(append* clos))))]
    [`(has-type (app ,f ,es ...) ,t)
      (let-values
        ([(f clof) (convert-to-closures f)]
         [(es clos) (map2 convert-to-closures es)])
        (match-let
          ([`(has-type ,ef ,tf) f])
          (let ([clo (gen-sym 'clo)]
                [tf* (function-to-closure-type tf)]
                [t* (function-to-closure-type t)])
            (values
              `(has-type
                 (let ([,clo (has-type ,ef ,tf*)])
                   (has-type
                     (app
                       (has-type
                         (vector-ref
                           (has-type ,clo ,tf*)
                           (has-type 0 Integer))
                         ((Vector _) ... -> ,t*))
                       (has-type ,clo (Vector _)) ,@es)
                     ,t*)) ,t*)
              `(,@clof ,@(append* clos))))))]
    [`(has-type (function-ref ,f) ,t)
      (values
        `(has-type
           (vector
             (has-type
               (function-ref ,f)
               ,t))
           (Vector ,t))
        '())]
    [`(has-type (let ([,x ,e]) ,b) ,t)
      (let-values
        ([(e cloe) (convert-to-closures e)]
         [(b clob) (convert-to-closures b)])
        (let ([t* (caddr b)])
          (values
            `(has-type (let ([,x ,e]) ,b) ,t*)
            `(,@cloe ,@clob))))]
    [`(define (,fn [,vs : ,ts] ...) : ,t ,e)
      (let-values ([(e clos) (convert-to-closures e)])
        (let* ([t* (caddr e)]
               [fn* (string->symbol (format "~s.direct" fn))]
               [ts* (map function-to-closure-type ts)]
               [args (map (lambda (v t) `[,v : ,t]) vs ts*)])
          (values
            `(define (,fn* ,@args) : ,t* ,e)
            `((define (,fn [clos : (Vector _)] ,@args) : ,t*
               (has-type
                 (app (has-type (function-ref ,fn*) (,@ts* -> ,t*))
                    ,@(map (lambda (v t) `(has-type ,v ,t)) vs ts))
                 ,t*)) ,@clos))))]
    [`(program ,type ,ds ... ,e)
      (let-values
        ([(ds* clods) (map2 convert-to-closures ds)]
         [(e* cloe) (convert-to-closures e)])
        `(program ,type ,@(append* clods) ,@ds* ,@cloe ,e*))]
    [`(has-type (if ,condition ,thns ,elss) ,t)
      (let-values
        ([(cond* cloc) (convert-to-closures condition)]
         [(thns* clot) (convert-to-closures thns)]
         [(elss* cloe) (convert-to-closures elss)])
        (values
          `(has-type (if ,cond* ,thns* ,elss*) ,(caddr thns*))
          (append cloc clot cloe)))]
    [`(has-type (,op ,es ...) ,t)
      (let-values
        ([(es clos) (map2 convert-to-closures es)])
        (values
          `(has-type (,op ,@es) ,t)
          (append* clos)))]
    [_ (values e '())]))
