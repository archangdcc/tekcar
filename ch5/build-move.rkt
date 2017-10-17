#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-move-R3)

(define (build-graph graph instrs)
  (for-each
    (lambda (instr)
      (match instr
        [`(movq (var ,y) (var ,x))
          (add-edge graph x y)]
        [`(if ,c ,thns ,elss)
          (begin
            (build-graph graph thns)
            (build-graph graph elss))]
        [_ (void)]))
    instrs))

(define (build-move-R3 p)
  (match p
    [`(program (,vars ... ,interf) ,type . ,instrs)
      (let ([move (make-graph (map (lambda (v) (car v)) vars))])
        (build-graph move instrs)
        `(program (,@vars ,interf ,move) ,type . ,instrs))]))
