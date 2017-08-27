#lang racket

(require "../utilities.rkt")
(provide flatten)


(define (malloc f)
  (lambda (e)
    (let-values ([(ret assign var) (f e)])
      (if (or (symbol? ret) (integer? ret))
        (values ret assign var)
        (let ([y (gensym)])
          (values y
                  (append assign `((assign ,y ,ret)))
                  (append var `(,y))))))))

;; use list append
;;
(define (flatten e)
  (match e
    [x #:when (or (symbol? x) (integer? x))
       (values x '() '())]
    [`(let ([,x ,e]) ,body)
      (let-values
        ([(ret₁ assign₁ var₁) (flatten e)]
         [(ret₂ assign₂ var₂) (flatten body)])
        (values ret₂
                (append assign₁ `((assign ,x ,ret₁)) assign₂)  ;; always assign in let clause
                (append var₁ `(,x) var₂)))]
    [`(program ,e)
      (let-values ([(ret assign var) ((malloc flatten) e)])    ;; only assign to non-arg in return
        `(program ,var . ,(append assign `((return ,ret)))))]
    [`(,op ,es ...)
      (let-values
        ([(rets assigns vars) (map3 (malloc flatten) es)])     ;; only assign to non-arg in op clause
        (values
          `(,op . ,rets)
          (append* assigns)
          (append* vars)))]))
