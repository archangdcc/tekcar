#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide build-interference-R4)

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
        [`(movq (,tagy ,y) (,tagx ,x))
          #:when
          (and
            (not (eq? tagy 'int))
            (not (eq? tagy 'stack-arg))
            (not (eq? tagx 'stack-arg)))
          (begin
            (set-for-each live
              (lambda (v)
                (cond
                  [(eq? v x) (void)]
                  [(eq? v y) (void)]
                  [else (add-edge* graph x v)])))
            instr)]
        [`(indirect-callq ,arg)
          (begin
            (set-for-each live
              (lambda (v)
                (for-each
                  (lambda (r)
                    (add-edge* graph r v))
                  (if
                    (let ([t (lookup v vars v)])
                      (and (pair? t) (eq? (car t) 'Vector)))
                    all-regs caller-regs))))
            instr)]
        [`(callq ,label)
          (begin
            (set-for-each live
              (lambda (v)
                (for-each
                  (lambda (r)
                    (add-edge* graph r v))
                  (if (and
                        (or
                          (eq? label 'collect)
                          (not (set-member? builtin-funs label)))
                        (let ([t (lookup v vars v)])
                          (and
                            (pair? t)
                            (eq? (car t) 'Vector))))
                    all-regs caller-regs))))
            instr)]
        [`(,op ... (,tag ,x))   ;; movzbq is handled here
          #:when (not (eq? tag 'stack-arg))
          (begin
            (set-for-each live
              (lambda (v)
                (cond
                  [(eq? v x) (void)]
                  [else (add-edge* graph x v)])))
            instr)]
        [_ instr]))  ;; deref and stack-arg
    live-after instrs))

(define (build-interference-R4 p)
  (match p
    [`(define (,label) ,argc
        (,vars ,maxstack ,live-after ,nulls)
        ,instrs ...)
      (let* ([graph (make-graph (map (lambda (v) (car v)) vars))]
             [instrs (build-graph graph live-after instrs vars)])
        `(define (,label) ,argc
           (,vars ,maxstack ,graph ,nulls)
           ,@instrs))]
    [`(program
        (,vars ,maxstack ,live-after ,nulls) ,type
        (defines ,ds ...)
        ,instrs ...)
      (let* ([graph (make-graph (map (lambda (v) (car v)) vars))]
             [instrs (build-graph graph live-after instrs vars)])
        `(program
           (,vars ,maxstack ,graph ,nulls) ,type
           (defines ,@(map build-interference-R4 ds))
           ,@instrs))]))
