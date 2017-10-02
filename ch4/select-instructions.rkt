#lang racket

(require "../global.rkt")

(provide select-instructions-R2)


(define (select-arg arg)
  (cond
    [(integer? arg) `(int ,arg)]
    [(eq? arg #t) `(int 1)]
    [(eq? arg #f) `(int 0)]
    [(symbol? arg) `(var ,arg)]))

(define (cc cmp)
  (match cmp
    ['< 'l]
    ['> 'g]
    ['eq? 'e]
    ['<= 'le]
    ['>= 'ge]))

(define (select-instr instr tail)
  (match instr
    [`(assign ,lhs (read))
      `((callq read_int)
        (movq (reg ,return-reg) (var ,lhs)) .
        ,tail)]
    [`(assign ,x (not ,x))
      `((xorq (int 1) (var ,x)) .
        ,tail)]
    [`(assign ,x (not ,y))
      `((movq ,(select-arg y) (var ,x))
        (xorq (int 1) (var ,x)) .
        ,tail)]
    [`(assign ,x (- ,x))
      `((negq (var ,x)) .
        ,tail)]
    [`(assign ,x (- ,y))
      `((movq ,(select-arg y) (var ,x))
        (negq (var ,x)) .
        ,tail)]
    [`(assign ,x (+ ,y ,x))
      `((addq ,(select-arg y) (var ,x)) .
        ,tail)]
    [`(assign ,x (+ ,x ,y))
      `((addq ,(select-arg y) (var ,x)) .
        ,tail)]
    [`(assign ,x (+ ,y ,z))
      `((movq ,(select-arg y) (var ,x))
        (addq ,(select-arg z) (var ,x)) .
        ,tail)]
    [`(assign ,x (,cmp ,y ,z))
      `((cmpq ,(select-arg z) ,(select-arg y))
        (set ,(cc cmp) (byte-reg al))
        (movzbq (byte-reg al) (var ,x)) .
        ,tail)]
    [`(assign ,x ,y)
      `((movq ,(select-arg y) (var ,x)) .
        ,tail)]
    [`(if (,cmp ,x ,y) ,thns ,elss)
      `((if (,cmp ,(select-arg x) ,(select-arg y))
          ,(foldr select-instr '() thns)
          ,(foldr select-instr '() elss)) .
        ,tail)]
    [`(return ,y)
      `((movq ,(select-arg y) (reg ,return-reg)) .
        ,tail)]))

(define (select-instructions-R2 e)
  (match e
    [`(program ,vars . ,instrs)
      (let ([x86*-instrs
             (foldr select-instr '() instrs)])
        `(program ,vars . ,x86*-instrs))]))
