#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide allocate-registers-R2)

(define (reg-satur interf vars satur-table)
  (for-each
    (lambda (var)
      (let ([adj (adjacent interf var)]
            [satur (hash-ref satur-table var)])
        (set-for-each adj
          (lambda (r)
            (let ([color (reg->color r)])
              (if color
                (set-add! satur color)
                (void)))))))
    vars))

(define (max-vert graph)
  (car
    (foldl
      (lambda (v tmp)
        (match tmp
          [`(,u ,m)
            (let ([n (set-count (hash-ref graph v))])
              (if (> n m) `(,v ,n) tmp))]))
      `(null -1) (hash-keys graph))))

(define (min-color satur c)
  (if (set-member? satur c)
    (min-color satur (+ 1 c)) c))

(define (max-bias bias)
  (car
    (foldl
      (lambda (c tmp)
        (match tmp
          [`(,d ,m)
            (let ([n (hash-ref bias c)])
              (if (> n m) `(,c ,n) tmp))]))
      `(null 0) (hash-keys bias))))

(define (bias-color color-table mv satur)
  (let ([bias (make-hash)]) ; color: number
    (begin
      (set-for-each mv
        (lambda (v)
          (if
            (hash-has-key? color-table v)  ; this move-related var is already colored
            (let ([c (hash-ref color-table v)])
              (if (not (set-member? satur c))  ; and this color is valid
                (hash-set! bias c (+ 1 (hash-ref bias c 0)))
                (void)))
            (void))))
      (if (equal? bias (make-hash))  ; no luck
        (min-color satur 0)  ; use the old method, find the minimum valid color
        (max-bias bias)))))

(define (dsatur interf move satur-table color-table)
  (if (equal? satur-table (make-hash)) (void)
    (let*
      ([v (max-vert satur-table)]
       [adj (adjacent interf v)]
       [satur (hash-ref satur-table v)]
       [mv (hash-ref move v)]
       [c (bias-color color-table mv satur)])
      (begin
        (hash-remove! satur-table v)
        (hash-set! color-table v c)
        (set-for-each adj
          (lambda (u)
            (if (hash-has-key? satur-table u)
              (set-add! (hash-ref satur-table u) c)
              (void))))
        (dsatur interf move satur-table color-table)))))

(define (color-graph interf move vars)
  (let
    ([satur-table
       (make-hash
         (map (lambda (v) (cons v (mutable-set))) vars))]
     [color-table (make-hash)])
    (begin
      (reg-satur interf vars satur-table)
      (dsatur interf move satur-table color-table)
      color-table)))

(define (alloc-reg color-table used-callee used-stack)
  (lambda (instr)
    (match instr
      [`(var ,x)
        (let ([c (hash-ref color-table x)])
          (if (< c reg-num)
            (let ([reg (color->reg c)])
              (begin
                (if (>= c caller-num)
                  (set-add! used-callee reg)
                  (void))
                `(reg ,reg)))
            (let ([idx (- c (- reg-num 1))])
              (begin
                (if (> idx (unbox used-stack))
                  (set-box! used-stack idx)
                  (void))
                `(deref rbp ,(* -8 idx))))))]
      [`(if (,cmp ,args ...) ,thns ,elss)
       `(if (,cmp ,@(map (alloc-reg color-table used-callee used-stack) args))
          ,(map (alloc-reg color-table used-callee used-stack) thns)
          ,(map (alloc-reg color-table used-callee used-stack) elss))]
      [`(,op ,args ...)
       `(,op ,@(map (alloc-reg color-table used-callee used-stack) args))]
      [_ instr])))

(define (allocate-registers-R2 p)
  (match p
    [`(program (,vars ... ,interf ,move) ,type . ,instrs)
      (let*
        ([color-table (color-graph interf move vars)]
         [used-callee (mutable-set)]
         [used-stack (box 0)]
         [instrs
           (map (alloc-reg color-table used-callee used-stack) instrs)])
        `(program
           (,(set->list used-callee) ,(unbox used-stack)) ,type .
           ,instrs))]))
