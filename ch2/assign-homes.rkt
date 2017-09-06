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
    [`(program (,vars . ,infos) . ,instrs)
     `(program
        ,(* (+ 1 (ceiling (/ (length vars) 2))) 16) .  ;; add up to multiples of 16 and add old rbp, return address
        ,(map (assign-home vars) instrs))]))
