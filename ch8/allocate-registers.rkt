#lang racket

(require data/heap)

(require "../utilities.rkt")
(require "../global.rkt")

(provide allocate-registers-R4)

(define (alloc-reg ctbl used-callee used-stk used-rstk)
  (lambda (instr)
    (match instr
      [`(var ,x)
        (let ([c (hash-ref ctbl x)])
          (cond
            [(eq? c 'null) '(null)]
            [(< c 0)  ;; rstk
             (let ([idx (- (- c) (- reg-num 1))])
               (if (> idx (unbox used-rstk))
                 (set-box! used-rstk idx)
                 (void))
               `(deref ,rstk-reg ,(* 8 (- idx))))]
            [(>= c reg-num)  ;; stk
             (let ([idx (- c (- reg-num 1))])
               (if (> idx (unbox used-stk))
                 (set-box! used-stk idx)
                 (void))
               `(deref rbp ,(* -8 idx)))]
            [else  ;; reg
             (let ([reg (color->reg c)])
               (if (>= c caller-num)
                 (set-add! used-callee reg)
                 (void))
               `(reg ,reg))]))]
      [`(if (,cmp ,args ...) ,thns ,elss)
       `(if (,cmp ,@(map (alloc-reg ctbl used-callee used-stk used-rstk) args))
          ,(map (alloc-reg ctbl used-callee used-stk used-rstk) thns)
          ,(map (alloc-reg ctbl used-callee used-stk used-rstk) elss))]
      [`(,op ,args ...)
       `(,op ,@(map (alloc-reg ctbl used-callee used-stk used-rstk) args))]
      [_ instr])))

(define (min-color sat c)
  (if (set-member? sat c)
    (min-color sat (+ 1 c)) c))

(define (min-color-vec sat c)
  (if (< (- c) reg-num)
    (if (set-member? sat (- c))
      (min-color-vec sat (- c 1)) (- c))
    (if (set-member? sat c)
      (min-color-vec sat (- c 1)) c)))

(define (select-color ctbl mvr sat t)
  (let ([frqs (make-frqs)]) ;;  color: freq
    (begin
      (set-for-each mvr
        (lambda (v)
          (cond
            [(hash-has-key? ctbl v)  ;; this move-related var is already colored
             (let ([c (hash-ref ctbl v)])
               (if (not (set-member? sat c))  ;; and this color is valid
                 (add-frqs frqs c)  ;; add to freq heap
                 (void)))]
            [(or (set-member? caller-save v)  ;; this var is a reg
                 (set-member? callee-save v))
             (let ([c (reg->color v)])
               (if (not (set-member? sat c))  ;; and this color is valid
                 (add-frqs frqs c)  ;; add to freq heap
                 (void)))]
            [else (void)])))
      (if (empty-frqs? frqs)  ;; no move-related found
        (match t
          [`(Vector . ,ts) (min-color-vec sat 0)]  ;; use the maximum negative valid color
          [_ (min-color sat 0)])  ;; use the minimum valid color
        (max-frqs frqs)))))  ;; use the max-freq move-related color

(define (dsat sats vars itbl mtbl ctbl nulls)
  (cond
    [(empty-sats? sats) ctbl]
    [else
      (match-let
        ([`(,v . ,sat) (max-sats sats)])  ;; next to be colored: var with max sat
        (if (set-member? nulls v)   ;; write-only
          (hash-set! ctbl v 'null)
          (let* ([t (lookup v vars)]
                 [adj (adjacent itbl v)]
                 [mvr (hash-ref mtbl v)]
                 [c (select-color ctbl mvr sat t)])
            (hash-set! ctbl v c)
            (set-for-each adj   ;; update sats for adjacent vars of the newly colored var
              (lambda (u)
                (if (set-member? nulls u)      ;; skip write-only
                  (void)
                  (if (sats-has-key? sats u)   ;; skip colored vars
                    (mod-sats sats u c)
                    (void)))))))
        (dsat sats vars itbl mtbl ctbl nulls))]))

(define (init-sats vars itbl)
  (let ([sats (make-sats)])
    (for-each   ;; add all vars with empty sets to sats
      (lambda (var)
        (add-sats sats (car var) (mutable-set)))
      vars)
    (for-each   ;; interf with regs;
      (lambda (r)
        (if (hash-has-key? itbl r)
          (let ([adj (adjacent itbl r)]
                [c (reg->color r)])
            (set-for-each adj
              (lambda (v)
                (mod-sats sats v c))))
          (void)))
      all-regs)
    sats))

(define (init-rstk n instrs)
  (cond
    [(zero? n) instrs]
    [else
      (init-rstk
        (- n 1)
        `((movq (int 0) (deref r15 0))
          (addq (int 8) (reg r15)) . ,instrs))]))

(define (elim-null instr tail)
  (match instr
    [`(if (,cmp ,x ,y) ,thns ,elss)
     `((if (,cmp ,x ,y)
         ,(foldr elim-null '() thns)
         ,(foldr elim-null '() elss)) . ,tail)]
    [`(,op ,arg (null)) tail]
    [_ (cons instr tail)]))

(define (allocate-registers-R4 p)
  (match p
    [`(define (,label) ,argc
        (,vars ,maxstack ,itbl ,mtbl ,nulls)
        ,instrs ...)
      (let*
        ([ctbl
           (dsat (init-sats vars itbl)
                 vars itbl mtbl
                 (make-hash) nulls)]
         [used-callee (mutable-set)]
         [used-stk (box 0)]
         [used-rstk (box 0)]
         [instrs
           (map (alloc-reg ctbl used-callee used-stk used-rstk) instrs)]
         [nrstk (unbox used-rstk)]
         [instrs (init-rstk nrstk instrs)]
         [instrs (foldr elim-null '() instrs)])
        `(define (,label) ,argc
           (,(set->list used-callee)
            ,(+ (unbox used-stk) maxstack)
            ,(unbox used-rstk))
           ,@instrs))]
    [`(program
        (,vars ,maxstack ,itbl ,mtbl ,nulls) ,type
        (defines ,ds ...)
        ,instrs ...)
      (let*
        ([ctbl
           (dsat (init-sats vars itbl)
                 vars itbl mtbl
                 (make-hash) nulls)]
         [used-callee (mutable-set)]
         [used-stk (box 0)]
         [used-rstk (box 0)]
         [instrs
           (map (alloc-reg ctbl used-callee used-stk used-rstk) instrs)]
         [nrstk (unbox used-rstk)]
         [instrs (init-rstk nrstk instrs)]
         [instrs (foldr elim-null '() instrs)])
        `(program
           (,(set->list used-callee)
            ,(+ (unbox used-stk) maxstack)
            ,(unbox used-rstk)) ,type
           (defines ,@(map allocate-registers-R4 ds))
           ,@instrs))]))
