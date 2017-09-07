#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide flatten)


(define (malloc f)
  (lambda (e)
    (let-values ([(ret assign var) (f e)])
      (if (or (symbol? ret) (integer? ret))
        (values ret assign var)
        (let ([y (gen-sym 'tmp)])
          (values y
                  (append assign `((assign ,y ,ret)))
                  (append var `(,y))))))))

;; use list append
;;
(define (flat e)
  (match e
    [x #:when (or (symbol? x) (integer? x))
       (values x '() '())]
    [`(let ([,x ,e]) ,body)
      (let-values
        ([(ret₁ assign₁ var₁) (flat e)]
         [(ret₂ assign₂ var₂) (flat body)])
        (values ret₂
                (append assign₁ `((assign ,x ,ret₁)) assign₂)  ;; always assign in let clause
                (append var₁ `(,x) var₂)))]
    [`(program ,e)
      (let-values ([(ret assign var) ((malloc flat) e)])    ;; only assign to non-arg in return
        `(program ,var . ,(append assign `((return ,ret)))))]
    [`(,op ,es ...)
      (let-values
        ([(rets assigns vars) (map3 (malloc flat) es)])     ;; only assign to non-arg in op clause
        (values
          `(,op . ,rets)
          (append* assigns)
          (append* vars)))]))

(define (flatten e)
  (init-sym)
  (flat e))
