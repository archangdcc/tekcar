#lang racket

(require "../utilities.rkt")
(provide flatten)

;; use list append
;;
;; (define (flatten e)
;;   (match e
;;     [x #:when (or (symbol? x) (integer? x))
;;        (values e '() '())]
;;     ['(read)
;;      (let ([y (gensym)])
;;        (values y `((assign ,y (read))) `(,y)))]
;;     [`(let ([,x ,e]) ,body)
;;       (let-values
;;         ([(ret₁ assign₁ var₁) (flatten e)]
;;          [(ret₂ assign₂ var₂) (flatten body)])
;;         (values ret₂
;;                 (append assign₁ `((assign ,x ,ret₁)) assign₂)
;;                 (append var₁ `(,x) var₂)))]
;;     [`(program ,e)
;;       (let-values ([(ret assign var) (flatten e)])
;;         `(program ,var . ,(append assign `((return ,ret)))))]
;;     [`(,op ,es ...)
;;       (let ([y (gensym)])
;;         (let-values
;;           ([(ret assign var) (map3 flatten es)])
;;           (values y
;;               (foldr
;;                 (lambda (a b) (append a b))
;;                 `((assign ,y (,op . ,ret))) assign)
;;               (foldr
;;                 (lambda (a b) (append a b))
;;                 `(,y) var))))]))


;; use lambda
(define (flatten e)
  (match e
    [x #:when (or (symbol? x) (integer? x))
       (values e (lambda (assign) assign) (lambda (var) var))]
    ['(read)
     (let ([y (gensym)])
       (values y
         (lambda (assign)
           `((assign ,y (read)) . ,assign))
         (lambda (var)
           `(,y . ,var))))]
    [`(let ([,x ,e]) ,body)
      (let-values
        ([(ret₁ k₁-assign k₁-var) (flatten e)]
         [(ret₂ k₂-assign k₂-var) (flatten body)])
        (values ret₂
          (lambda (assign)
            (k₁-assign `((assign ,x ,ret₁) . ,(k₂-assign assign))))
          (lambda (var)
            (k₁-var `(,x . ,(k₂-var var))))))]
    [`(program ,e)
      (let-values ([(ret k-assign k-var) (flatten e)])
        `(program ,(k-var '()) .
          ,(k-assign `((return ,ret)))))]
    [`(,op ,es ...)
      (let ([y (gensym)])
        (let-values
          ([(ret k-assign k-var) (map3 flatten es)])
          (values y
            (lambda (assign)
              (foldr
                (lambda (f x) (f x))
                `((assign ,y (,op . ,ret)) . ,assign) k-assign))
            (lambda (var)
              (foldr
                (lambda (f x) (f x))
                `(,y . ,var) k-var)))))]))
