#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-interference)

(define (build-graph graph live-after instrs)
  (for-each
    (lambda (live instr)
      (match instr
        [`(movq (var ,y) (var ,x))
          (set-for-each live
            (lambda (v)
              (cond
                [(eq? v x) (void)]
                [(eq? v y) (void)]
                [else (add-edge graph x v)])))]
        [`(,op ... (var ,x))
          (set-for-each live
            (lambda (v)
              (cond
                [(eq? v x) (void)]
                [else (add-edge graph x v)])))]
        [`(callq ,label)
          (set-for-each live
            (lambda (v)
              (for-each
                (lambda (r)
                  (add-edge graph r v))
                caller-regs)))]
        [_ (void)]))    ;; may need extra work for reg args
    live-after instrs))

(define (build-interference p)
  (match p
    [`(program (,vars ... ,live-after) . ,instrs)
      (let ([graph
             (make-graph vars)])
        (build-graph graph live-after instrs)
        `(program (,@vars ,graph) . ,instrs))]))
