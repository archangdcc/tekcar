#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-move)

(define (build-graph graph instrs)
  (for-each
    (lambda (instr)
      (match instr
        [`(movq (var ,y) (var ,x))
          (add-edge graph x y)]
        [_ (void)]))
    instrs))

(define (build-move p)
  (match p
    [`(program (,vars ... ,interf) . ,instrs)
      (let ([move (make-graph vars)])
        (build-graph move instrs)
        `(program (,@vars ,interf ,move) . ,instrs))]))
