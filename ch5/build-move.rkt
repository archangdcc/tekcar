#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-move-R3)

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

(define (build-move-R3 p)
  (match p
    [`(program (,vars ... ,interf ,nulls) ,type . ,instrs)
      (let ([move (make-graph (map (lambda (v) (car v)) vars))])
        (build-graph move instrs nulls)
        `(program (,@vars ,interf ,move ,nulls) ,type . ,instrs))]))
