#lang racket

(provide uncover-live)

(define (vars-assort instr)  ;; return all-vars, w-vars, r-vars
  (match instr
    [`(movq (var ,y) (var ,x))
      (values (set x y) (set x) (set y))]
    [`(movq ,arg (var ,x))        ;; arg: int or reg
      (values (set x) (set x) (set))]
    [`(addq (var ,y) (var ,x))
      (values (set x y) (set x) (set x y))]
    [`(addq ,arg (var ,x))        ;; arg: int or reg
      (values (set x) (set x) (set x))]
    [`(,op (var ,x) (reg ,r))     ;; need more work if r != rax
      (values (set x) (set) (set x))]
    [`(negq (var ,x))
      (values (set x) (set x) (set x))]
    [`(callq ,label)
      (values (set) (set) (set))]
    [_ (values (set) (set) (set))]))

(define (uncover-live-helper live-after instrs)
  ;; the car of the result should be ignored
  ;; because it is the live set before first instr
  (if (eq? instrs '()) `(,live-after)
    (let-values
      ([(a-vars w-vars r-vars)
        (vars-assort (car instrs))])
      (let ([rec
             (uncover-live-helper live-after (cdr instrs))])
        (cons
          (set-union
            (set-subtract (car rec) w-vars)
            r-vars)
          rec)))))

(define (uncover-live e)
  (match e
    [`(program (,vars . ,infos) . ,instrs)
      (let ([live-after
             (cdr (uncover-live-helper (set) instrs))])
        `(program (,vars ,live-after . ,infos) . ,instrs))]))
