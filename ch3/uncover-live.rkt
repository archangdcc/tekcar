#lang racket

(provide uncover-live)

(define (vars-assort stmt)  ;; return all-vars, w-vars, r-vars
  (match stmt
    [`(movq (var ,y) (var ,x))
      (values (set x y) (set x) (set y))]
    [`(movq ,arg (var ,x))        ;; arg: int or reg
      (values (set x) (set x) (set))]
    [`(addq (var ,y) (var ,x))
      (values (set x y) (set x) (set x y))]
    [`(addq ,arg (var ,x))        ;; arg: int or reg
      (values (set x) (set x) (set x))]
    [`(,op (var ,x) (reg ,r))
      (values (set x) (set) (set x))]
    [`(negq (var ,x))
      (values (set x) (set x) (set x))]
    [`(callq ,label)
      (values (set) (set) (set))]
    [`(return (int ,x))
      (values (set) (set) (set))]
    [`(return (var ,x))
      (values (set x) (set) (set x))]
    [_ (values (set) (set) (set))]))

(define (uncover-live-helper live-after stmts)
  ;; the car of the result should be ignored
  ;; because it is the live set before first stmt
  (if (eq? stmts '()) `(,live-after)
    (let-values
      ([(a-vars w-vars r-vars)
        (vars-assort (car stmts))])
      (let ([rec
             (uncover-live-helper live-after (cdr stmts))])
        (cons
          (set-union
            (set-subtract (car rec) w-vars)
            r-vars)
          rec)))))

(define (uncover-live e)
  (match e
    [`(program (,vars ,infos ...) . ,stmts)
      (let ([live-after
             (cdr (uncover-live-helper (set) stmts))])
        `(program (,vars ,live-after ,infos) . ,stmts))]))
