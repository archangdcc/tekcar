#lang racket

(require "../global.rkt")

(provide select-instructions-R6)


(define (select-arg arg)
  (cond
    [(integer? arg) `(int ,arg)]
    [(boolean? arg) (if arg `(int 1) `(int 0))]
    [(symbol? arg) `(var ,arg)]))

(define (tag types n)
  (bitwise-ior
    (arithmetic-shift
      (foldr
        (lambda (type tag)
          (match type
            [`(Vector . ,ts)
              (bitwise-ior (arithmetic-shift tag 1) 1)]
            ['Any
              (bitwise-ior (arithmetic-shift tag 1) 1)]
            [_ (arithmetic-shift tag 1)]))
        0 types) 7)
    (arithmetic-shift n 1)
    1))

(define (anytag t)
  (match t
    ['Integer 1]
    ['Boolean 4]
    ['Void 5]
    [_ (match (car t)
         ['Vector 2]
         ['Vectorof 2]
         [_ 3])]))

(define (caller-move-args vs regs)
  (cond
    [(null? vs) '()]
    [(null? regs)
     (caller-move-args vs 0)]
    [(number? regs)
     (cons `(movq ,(select-arg (car vs)) (stack-arg ,regs))
           (caller-move-args (cdr vs) (+ 8 regs)))]
    [(pair? regs)
     (cons `(movq ,(select-arg (car vs)) (reg ,(car regs)))
           (caller-move-args (cdr vs) (cdr regs)))]))

(define (callee-move-args vs regs)
  (cond
    [(null? vs) '()]
    [(null? regs)
     (callee-move-args vs 0)]
    [(number? regs)
     (cons `(movq (stack-arg ,regs) (var ,(car vs)))
           (callee-move-args (cdr vs) (+ 8 regs)))]
    [(pair? regs)
     (cons `(movq (reg ,(car regs)) (var ,(car vs)))
           (callee-move-args (cdr vs) (cdr regs)))]))

(define (select-instr maxstack)
  (lambda (instr tail)
    (match instr
      [`(assign ,lhs (inject ,v Void))
       `((movq (int 5) (var ,lhs)) . ,tail)]
      [`(assign ,lhs (inject ,v ,t))
        #:when (or (equal? t 'Integer) (equal? t 'Boolean))
       `((movq ,(select-arg v) (var ,lhs))
         (salq (int 3) (var ,lhs))
         (orq (int ,(anytag t)) (var ,lhs)) .
         ,tail)]
      [`(assign ,lhs (inject ,v ,t))
       `((movq ,(select-arg v) (var ,lhs))
         (orq (int ,(anytag t)) (var ,lhs)) .
         ,tail)]
      [`(assign ,lhs (project ,v Void))
       `((movq ,(select-arg v) (var ,lhs))
         (andq (int 7) (var ,lhs))
         (if (eq? (var ,lhs) (int 5))
           ((movq (int 0) (var ,lhs)))
           ((callq exit))) .
         ,tail)]
      [`(assign ,lhs (project ,v ,t))
        #:when (or (equal? t 'Integer) (equal? t 'Boolean))
       `((movq ,(select-arg v) (var ,lhs))
         (andq (int 7) (var ,lhs))
         (if (eq? (var ,lhs) (int ,(anytag t)))
           ((movq ,(select-arg v) (var ,lhs))
            (sarq (int 3) (var ,lhs)))
           ((callq exit))) .
         ,tail)]
      [`(assign ,lhs (project ,v ,t))
       `((movq ,(select-arg v) (var ,lhs))
         (andq (int 7) (var ,lhs))
         (if (eq? (var ,lhs) (int ,(anytag t)))
           ((movq (int 7) (var ,lhs))
            (notq (var ,lhs))
            (andq ,(select-arg v) (var ,lhs)))
           ((callq exit))) .
         ,tail)]
      [`(assign ,lhs (void))
       `((movq (int 0) (var ,lhs)) .
         ,tail)]
      [`(assign ,lhs (global-value ,v))
       `((movq (global-value ,v) (var ,lhs)) .
         ,tail)]
      [`(assign ,lhs (vector-ref ,vec ,n))
       `((movq ,(select-arg vec) (reg ,vec-reg))
         (movq (deref ,vec-reg 0) (reg ,temp-reg))
         (andq (int 126) (reg ,temp-reg))
         (sarq (int 1) (reg ,temp-reg))
         (if (< (reg ,temp-reg) ,(select-arg n))
           ((callq exit))
           ((movq ,(select-arg n) (reg ,temp-reg))
            (addq (int 1) (reg ,temp-reg))          ;; n+1,  use incq?
            (salq (int 3) (reg ,temp-reg))          ;; (n+1)*8
            (addq (reg ,temp-reg) (reg ,vec-reg))
            (movq (deref ,vec-reg 0) (var ,lhs)))) .
         ,tail)]
      [`(assign ,lhs (vector-set! ,vec ,n ,arg))
       `((movq ,(select-arg vec) (reg ,vec-reg))
         (movq (deref ,vec-reg 0) (reg ,temp-reg))
         (andq (int 126) (reg ,temp-reg))
         (sarq (int 1) (reg ,temp-reg))
         (if (< (reg ,temp-reg) ,(select-arg n))
           ((callq exit))
           ((movq ,(select-arg n) (reg ,temp-reg))
            (addq (int 1) (reg ,temp-reg))          ;; n+1,  use incq?
            (salq (int 3) (reg ,temp-reg))          ;; (n+1)*8
            (addq (reg ,temp-reg) (reg ,vec-reg))
            (movq ,(select-arg arg) (deref ,vec-reg 0))
            (movq (int 0) (var ,lhs)))) .
         ,tail)]
      [`(assign ,lhs (allocate ,n (Vector . ,types)))
       `((movq (global-value free_ptr) (var ,lhs))
         (addq (int ,(* 8 (+ n 1))) (global-value free_ptr))
         (movq (var ,lhs) (reg ,vec-reg))
         (movq (int ,(tag types n)) (deref ,vec-reg 0)) .
         ,tail)]
      [`(collect ,b)
       `((movq (reg ,rstk-reg) (reg rdi))
         (movq (int ,b) (reg rsi))
         (callq collect))]
      [`(assign ,lhs (function-ref ,f))
        `((leaq (function-ref ,f) (var ,lhs)) .
          ,tail)]
      [`(assign ,lhs (app (function-ref ,f) ,args ...))
        (let* ([instrs (caller-move-args args arg-regs)])
          (set-box! maxstack (max (unbox maxstack) (- (length args) arg-num)))
          `(,@instrs
             (callq ,f)
             (movq (reg rax) (var ,lhs)) .
             ,tail))]
      [`(assign ,lhs (app ,fn ,args ...))
        (let* ([instrs (caller-move-args args arg-regs)])
          (set-box! maxstack (max (unbox maxstack) (- (length args) arg-num)))
          `(,@instrs
             (indirect-callq (var ,fn))
             (movq (reg rax) (var ,lhs)) .
             ,tail))]
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
            ,(foldr (select-instr maxstack) '() thns)
            ,(foldr (select-instr maxstack) '() elss)) .
          ,tail)]
      [`(return ,y)
        `((movq ,(select-arg y) (reg ,return-reg)) .
          ,tail)])))

(define (select-instructions-R6 e)
  (match e
    [`(define (,label [,vs : ,ts] ...) : ,t
        ,vars ,instrs ...)
      (let* ([maxstack (box 0)]
             [init-instrs (callee-move-args vs arg-regs)]
             [x86*-instrs (foldr (select-instr maxstack) '() instrs)])
        `(define (,label) ,(length vs)
           (,vars ,(unbox maxstack))
           ,@init-instrs ,@x86*-instrs))]
    [`(program ,vars ,type (defines ,ds ...) ,instrs ...)
      (let* ([maxstack (box 0)]
             [x86*-instrs
               (foldr (select-instr maxstack) '() instrs)])
        `(program
           (,vars ,(unbox maxstack)) ,type
           (defines ,@(map select-instructions-R6 ds))
           ,@x86*-instrs))]))