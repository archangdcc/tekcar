#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-interference-R3)

(define (build-graph graph live-after instrs vars)
  (map
    (lambda (live instr)
      (match instr
        [`(if (,cmp ,x ,y) ,thns ,thn-live ,elss ,els-live)
          (let
            ([thns (build-graph graph thn-live thns vars)]
             [elss (build-graph graph els-live elss vars)])
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
                  (if (and
                        (eq? label 'collect)
                        (let ([t (lookup v vars)])
                          (and
                            (pair? t)
                            (eq? (car t) 'Vector))))
                    all-regs caller-regs))))
            instr)]
        [_ instr]))    ;; may need extra work for reg args
    live-after instrs))

(define (build-interference-R3 p)
  (match p
    [`(program (,vars ... ,live-after) ,type . ,instrs)
      (let* ([graph (make-graph (map (lambda (v) (car v)) vars))]
             [instrs (build-graph graph live-after instrs vars)])
        `(program (,@vars ,graph) ,type . ,instrs))]))
