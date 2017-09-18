#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide allocate-registers)

(define (reg-satur graph vars satur-table)
  (for-each
    (lambda (var)
      (let ([adj (adjacent graph var)]
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

(define (dsatur graph satur-table color-table max-color)
  (if (equal? satur-table (make-hash)) max-color
    (let*
      ([v (max-vert satur-table)]
       [adj (adjacent graph v)]
       [c (min-color (hash-ref satur-table v) 0)])
      (begin
        (hash-remove! satur-table v)
        (hash-set! color-table v c)
        (set-for-each adj
          (lambda (u)
            (if (hash-has-key? satur-table u)
              (set-add! (hash-ref satur-table u) c)
              (void))))
        (dsatur graph satur-table color-table
                (if (> c max-color) c max-color))))))

(define (color-graph graph vars)
  (let
    ([satur-table
       (make-hash
         (map (lambda (v) (cons v (mutable-set))) vars))]
     [color-table
       (make-hash
         (map (lambda (v) (cons v (mutable-set))) vars))])
    (begin
      (reg-satur graph vars satur-table)
      (let ([max-color (dsatur graph satur-table color-table -1)])
        (values color-table max-color)))))

(define (alloc-reg color-table)
  (lambda (instr)
    (match instr
      [`(var ,x)
        (let ([c (hash-ref color-table x)])
          (if (< c reg-num)
            `(reg ,(color->reg c))
            `(deref rbp ,(* -8 (- c (- reg-num 1))))))]
      [`(,op ,args ...)
       `(,op ,@(map (alloc-reg color-table) args))]
      [_ instr])))

(define (allocate-registers p)
  (match p
    [`(program (,vars ... ,graph) . ,instrs)
      (let-values
        ([(color-table max-color)
          (color-graph graph vars)])
        `(program ,(+ 1 max-color)
          ,@(map (alloc-reg color-table) instrs)))]))
