#lang racket

(require "../global.rkt")

(provide select-instructions)


(define (select-arg arg)
  (cond
    [(integer? arg) `(int ,arg)]
    [(symbol? arg) `(var ,arg)]))

(define (select-instr instr tail)
  (match instr
    [`(assign ,lhs (read))
      `((callq read_int)
        (movq (reg ,return-reg) (var ,lhs)) .
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
    [`(assign ,x ,y)
      `((movq ,(select-arg y) (var ,x)) .
        ,tail)]
    [`(return ,y)
      `((movq ,(select-arg y) (reg ,return-reg)) .
        ,tail)]))

(define (select-instructions e)
  (match e
    [`(program ,vars . ,instrs)
      (let ([x86*-instrs
             (foldr select-instr '() instrs)])
        `(program (,vars) . ,x86*-instrs))]))
