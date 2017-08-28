#lang racket

(provide assign-homes)


(define (map-stk vars x)
    (if (equal? (car vars) x) -8
      (- (map-stk (cdr vars) x) 8)))

(define (assign-home vars)
  (lambda (instr)
    (match instr
      [`(,op (var ,x) (var ,y))
       `(,op (deref rbp ,(map-stk vars x)) (deref rbp ,(map-stk vars y)))]
      [`(,op (var ,x) . ,es)
       `(,op (deref rbp ,(map-stk vars x)) . ,es)]
      [`(,op ,e (var ,x))
       `(,op ,e (deref rbp ,(map-stk vars x)))]
      [_ instr])))

(define (assign-homes e)
  (match e
    [`(program ,vars . ,instrs)
     `(program
        ,(* (+ 1 (ceiling (/ (length vars) 2))) 16) .  ;; add up to multiples of 16 and add old rbp, return address
        ,(map (assign-home vars) instrs))]))
