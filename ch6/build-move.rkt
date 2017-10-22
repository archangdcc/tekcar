#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-move-R4)

(define (build-graph graph instrs nulls)
  (for-each
    (lambda (instr)
      (match instr
        [`(movq (var ,y) (var ,x))
          (if (or (set-member? nulls x) (set-member? nulls y))
            (void)
            (add-edge graph x y))]
        [`(if ,c ,thns ,elss)
          (begin
            (build-graph graph thns nulls)
            (build-graph graph elss nulls))]
        [_ (void)]))
    instrs))

(define (build-move-R4 p)
  (match p
    [`(define (,label) ,argc
        (,vars ,maxstack ,interf ,nulls)
        ,instrs ...)
      (let ([move (make-graph (map (lambda (v) (car v)) vars))])
        (build-graph move instrs nulls)
        `(define (,label) ,argc
           (,vars ,maxstack ,interf ,move ,nulls)
           ,@instrs))]
    [`(program
        (,vars ,maxstack ,interf ,nulls) ,type
        (defines ,ds ...)
        ,instrs ...)
      (let ([move (make-graph (map (lambda (v) (car v)) vars))])
        (build-graph move instrs nulls)
        `(program
           (,vars ,maxstack ,interf ,move ,nulls) ,type
           (defines ,@(map build-move-R4 ds))
           ,@instrs))]))
