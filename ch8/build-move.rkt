#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-move-R6)

(define (build-graph graph instrs nulls)
  (for-each
    (lambda (instr)
      (match instr
        [`(movq (,tagy ,y) (,tagx ,x))
          #:when
          (and
            (not (set-member? nulls x))
            (not (set-member? nulls y))
            (not (set-member? nulls y))
            (not (eq? x temp-reg))
            (not (eq? tagy 'stack-arg))
            (not (eq? tagx 'stack-arg)))
          (add-edge* graph x y)]
        [`(if ,c ,thns ,elss)
          (begin
            (build-graph graph thns nulls)
            (build-graph graph elss nulls))]
        [_ (void)]))
    instrs))

(define (build-move-R6 p)
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
           (defines ,@(map build-move-R6 ds))
           ,@instrs))]))
