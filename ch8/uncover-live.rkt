#lang racket

(require "../global.rkt")

(provide uncover-live-R6)

(define (vars arg)
  (match arg
    [`(var ,x) (set x)]
    [`(reg ,r)
      #:when (not (equal? r temp-reg))
      (set r)]
    [_ (set)]))

(define (deref arg)
  (match arg
    [`(deref ,r ,n) (set r)]
    [_ (set)]))

(define (vars-assort instr)  ;; return all-vars, w-vars, r-vars
  (match instr
    [`(movq ,x ,y)
      (let ([sx (vars x)]
            [sy (vars y)])
        (values
          (set-union sx sy)
          sy
          (set-union sx (deref x) (deref y))))]
    [`(cmpq ,x ,y)
      (let ([sx (vars x)]
            [sy (vars y)])
        (values (set-union sx sy) (set) (set-union sx sy)))]
    [`(leaq (function-ref ,label) (var ,x))
      (values (set x) (set x) (set))]
    [`(indirect-callq (var ,x))
      (values (set x) (set) (set x))]
    [`(callq ,label)
      (values (set) (set) (set))]
    [`(set ,cc ,x)    ;; x is always (byte-reg al)
      (values (set) (set) (set))]
    [`(movzbq ,x ,y)  ;; x is always (byte-reg al)
      (let ([sy (vars y)])
        (values sy sy (deref y)))]
    [`(,op ,x)        ;; negq orq
      (let ([sx (vars x)])
        (values sx sx (set-union sx (deref x))))]
    [`(,op ,x ,y)     ;; addq xorq andq salq sarq
      (let ([sx (vars x)]
            [sy (vars y)])
        (values
          (set-union sx sy)
          sy
          (set-union sx sy (deref x) (deref y))))]))

(define (uncover-live live-after instrs)
  ;; the car of the result should be ignored
  ;; because it is the live set before first instr
  (if (eq? instrs '()) (values `(,live-after) instrs)
    (let-values
      ([(cdr-live-after cdr-new-instrs)
        (uncover-live live-after (cdr instrs))])
      (match (car instrs)
        [`(if (,cmp ,x ,y) ,thns ,elss)
         (let-values
           ([(thn-lives thn-instrs)
             (uncover-live (car cdr-live-after) thns)]
            [(els-lives els-instrs)
             (uncover-live (car cdr-live-after) elss)])
           (let ([sx (vars x)]
                 [sy (vars y)])
             (values
               (cons
                 (set-union
                   (car thn-lives)
                   (car els-lives)
                   sx sy)
                 cdr-live-after)
               (cons
                 `(if (,cmp ,x ,y)
                    ,thn-instrs ,(cdr thn-lives)
                    ,els-instrs ,(cdr els-lives))
                 cdr-new-instrs))))]
        [_
         (let-values
           ([(a-vars w-vars r-vars)
             (vars-assort (car instrs))])
           (values
             (cons
               (set-union
                 (set-subtract (car cdr-live-after) w-vars)
                 r-vars)
               cdr-live-after)
             (cons
               (car instrs)
               cdr-new-instrs)))]))))

(define (uncover-live-R6 e)
  (match e
    [`(define (,label) ,argc
        (,vars ,maxstack)
        ,instrs ...)
      (let-values
        ([(live-after new-instrs)
          (uncover-live (set) instrs)])
        `(define (,label) ,argc
           (,vars ,maxstack ,(cdr live-after))
           ,@new-instrs))]
    [`(program
        (,vars ,maxstack) ,type
        (defines ,ds ...)
        ,instrs ...)
      (let-values
        ([(live-after new-instrs)
          (uncover-live (set) instrs)])
        `(program
           (,vars ,maxstack ,(cdr live-after)) ,type
           (defines ,@(map uncover-live-R6 ds))
           ,@new-instrs))]))
