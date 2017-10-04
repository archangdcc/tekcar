#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-interference-R2)

(define (build-graph graph live-after instrs)
  (map
    (lambda (live instr)
      (match instr
        [`(if (,cmp ,x ,y) ,thns ,thn-live ,elss ,els-live)
          (let
            ([thns (build-graph graph thn-live thns)]
             [elss (build-graph graph els-live elss)])
            `(if (,cmp ,x ,y) ,thns ,elss))]
        [`(cmpq ,x ,y) instr]
        [`(movq (var ,y) (var ,x))
          (begin
            (set-for-each live
              (lambda (v)
                (cond
                  [(eq? v x) (void)]
                  [(eq? v y) (void)]
                  [else (add-edge graph x v)])))
            instr)]
        [`(,op ... (var ,x))   ;; movzbq is handled here
          (begin
            (set-for-each live
              (lambda (v)
                (cond
                  [(eq? v x) (void)]
                  [else (add-edge graph x v)])))
            instr)]
        [`(callq ,label)
          (begin
            (set-for-each live
              (lambda (v)
                (for-each
                  (lambda (r)
                    (add-edge graph r v))
                  caller-regs)))
            instr)]
        [_ instr]))    ;; may need extra work for reg args
    live-after instrs))

(define (build-interference-R2 p)
  (match p
    [`(program (,vars ... ,live-after) ,type . ,instrs)
      (let* ([graph (make-graph vars)]
             [instrs (build-graph graph live-after instrs)])
        `(program (,@vars ,graph) ,type . ,instrs))]))
