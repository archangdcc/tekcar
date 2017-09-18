#lang racket

(provide assign-homes)


(define (map-stk vars x)
    (if (equal? (car vars) x) -8
      (- (map-stk (cdr vars) x) 8)))

(define (assign-home vars)
  (lambda (instr)
    (match instr
      [`(var ,x) `(deref rbp ,(map-stk vars x))]
      [`(,op ,e) `(,op ,((assign-home vars) e))]
      [`(,op ,e1 ,e2)
       `(,op ,((assign-home vars) e1) ,((assign-home vars) e2))]
      [_ instr])))

(define (assign-homes e)
  (match e
    [`(program ,vars . ,instrs)
     `(program
        ,(length vars) .
        ,(map (assign-home vars) instrs))]))
