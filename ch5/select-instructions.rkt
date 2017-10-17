#lang racket

(require "../global.rkt")

(provide select-instructions-R3)


(define (select-arg arg)
  (cond
    [(integer? arg) `(int ,arg)]
    [(boolean? arg) (if arg `(int 1) `(int 0))]
    [(symbol? arg) `(var ,arg)]))

(define (tag types n)
  (bitwise-ior
    (arithmetic-shift
      (foldl
        (lambda (type tag)
          (if (eq? type 'Vector)
            (bitwise-ior (arithmetic-shift tag 1) 1)
            (arithmetic-shift tag 1)))
        0 types) 7)
    (arithmetic-shift n 1)
    1))

(define (select-instr instr tail)
  (match instr
    [`(assign ,lhs (void))
     `((movq (int 0) (var ,lhs)) .
       ,tail)]
    [`(assign ,lhs (global-value ,v))
     `((movq (global-value ,v) (var ,lhs)) .
       ,tail)]
    [`(assign ,lhs (vector-ref ,vec ,n))
     `((movq ,(select-arg vec) (reg ,vec-reg))
       (movq (deref ,vec-reg ,(* 8 (+ n 1))) (var ,lhs)) .
       ,tail)]
    [`(assign ,lhs (vector-set! ,vec ,n ,arg))
     `((movq ,(select-arg vec) (reg ,vec-reg))
       (movq ,(select-arg arg) (deref ,vec-reg ,(* 8 (+ n 1))))
       (movq (int 0) (var ,lhs)) .
       ,tail)]
    [`(assign ,lhs (allocate ,n (Vector ,type ...)))
     `((movq (global-value free_ptr) (var ,lhs))
       (addq (int ,(* 8 (+ n 1))) (global-value free_ptr))
       (movq (var ,lhs) (reg ,vec-reg))
       (movq (int ,(tag type n)) (deref ,vec-reg 0)) .
       ,tail)]
    [`(collect ,b)
     `((movq (reg ,rstk-reg) (reg rdi))
       (movq (int ,b) (reg rsi))
       (callq collect))]
    [`(assign ,lhs (read))
      `((callq read_int)
        (movq (reg ,return-reg) (var ,lhs)) .
        ,tail)]
    [`(assign ,x (not ,x))
      `((xorq (int 1) (var ,x)) .
        ,tail)]
    [`(assign ,x (not ,y))
      `((movq ,(select-arg y) (var ,x))
        (xorq (int 1) (var ,x)) .
        ,tail)]
    [`(assign ,x (- ,x))
      `((negq (var ,x)) .
        ,tail)]
    [`(assign ,x (- ,y))
      `((movq ,(select-arg y) (var ,x))
        (negq (var ,x)) .
        ,tail)]
    [`(assign ,x (+ ,y ,x))
      `((addq ,(select-arg y) (var ,x)) .
        ,tail)]
    [`(assign ,x (+ ,x ,y))
      `((addq ,(select-arg y) (var ,x)) .
        ,tail)]
    [`(assign ,x (+ ,y ,z))
      `((movq ,(select-arg y) (var ,x))
        (addq ,(select-arg z) (var ,x)) .
        ,tail)]
    [`(assign ,x (,cmp ,y ,z))
      `((cmpq ,(select-arg z) ,(select-arg y))
        (set ,(cc cmp) (byte-reg al))
        (movzbq (byte-reg al) (var ,x)) .
        ,tail)]
    [`(assign ,x ,y)
      `((movq ,(select-arg y) (var ,x)) .
        ,tail)]
    [`(if (,cmp ,x ,y) ,thns ,elss)
      `((if (,cmp ,(select-arg x) ,(select-arg y))
          ,(foldr select-instr '() thns)
          ,(foldr select-instr '() elss)) .
        ,tail)]
    [`(return ,y)
      `((movq ,(select-arg y) (reg ,return-reg)) .
        ,tail)]))

(define (select-instructions-R3 e)
  (match e
    [`(program ,vars ,type . ,instrs)
      (let ([x86*-instrs
             (foldr select-instr '() instrs)])
        `(program ,vars ,type . ,x86*-instrs))]))
