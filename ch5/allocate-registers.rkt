#lang racket

(require data/heap)

(require "../utilities.rkt")
(require "../global.rkt")

(provide allocate-registers-R3)

(define (alloc-reg ctbl used-callee used-stk used-rstk)
  (lambda (instr)
    (match instr
      [`(var ,x)
        (let ([c (hash-ref ctbl x)])
          (cond
            [(< c 0)  ;; rstk
             (let ([idx (- (- c) (- reg-num 1))])
               (if (> idx (unbox used-rstk))
                 (set-box! used-rstk idx)
                 (void))
               `(deref r15 ,(* -8 idx)))]
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

(define (min-color satur c)
  (if (set-member? satur c)
    (min-color satur (+ 1 c)) c))

(define (min-color-vec satur c)
  (if (< (- c) reg-num)
    (if (set-member? satur (- c))
      (min-color satur (- 1 c)) (- c))
    (if (set-member? satur c)
      (min-color satur (- 1 c)) c)))

(define (select-color ctbl mvr sat t)
  (let ([frqs (make-frqs)]) ;;  color: freq
    (begin
      (set-for-each mvr
        (lambda (v)
          (if
            (hash-has-key? ctbl v)  ; this move-related var is already colored
            (let ([c (hash-ref ctbl v)])
              (if (not (set-member? sat c))  ; and this color is valid
                (add-frqs frqs c)
                (void)))
            (void))))
      (if (empty-frqs? frqs)
        (match t
          [`(Vector ,ts ...) (min-color-vec sat 0)]
          [_ (min-color sat 0)])  ; use the minimum valid color
        (max-frqs frqs)))))  ; use the max-freq move-related color

(define (dsat sats vars itbl mtbl ctbl)
  (cond
    [(empty-sats? sats) ctbl]
    [else
      (match-let*
        ([`(,v . ,sat) (max-sats sats)]
         [t (lookup v vars)]
         [adj (adjacent itbl v)]
         [mvr (hash-ref mtbl v)]
         [c (select-color ctbl mvr sat t)])
        (hash-set! ctbl v c)
        (set-for-each adj
          (lambda (u)
            (if (sats-has-key? sats u)
              (mod-sats sats u c)
              (void))))
        (dsat sats vars itbl mtbl ctbl))]))

(define (init-sats vars itbl)
  (let ([sats (make-sats)])
    (for-each
      (lambda (var)
        (let* ([v (car var)]
               [adj (adjacent itbl v)]
               [sat (mutable-set)])
          (set-for-each adj
            (lambda (r)
              (let ([c (reg->color r)])
                (if c
                  (set-add! sat c)
                  (void)))))
          (add-sats sats v sat)))
      vars)
    sats))

(define (allocate-registers-R3 p)
  (match p
    [`(program (,vars ... ,itbl ,mtbl) ,type . ,instrs)
      (let*
        ([ctbl
           (dsat (init-sats vars itbl)
                 vars itbl mtbl
                 (make-hash))]
         [used-callee (mutable-set)]
         [used-stk (box 0)]
         [used-rstk (box 0)]
         [instrs
           (map (alloc-reg ctbl used-callee used-stk used-rstk) instrs)])
        `(program
           (,(set->list used-callee)
            ,(unbox used-stk)
            ,(unbox used-rstk))
           ,type . ,instrs))]))
