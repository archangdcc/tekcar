#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide flatten-R2)


(define (malloc f)
  (lambda (e)
    (let-values ([(ret assign var) (f e)])
      (if (or (symbol? ret) (integer? ret) (boolean? ret))
        (values ret assign var)
        (let ([y (gen-sym 'tmp)])
          (values y
                  (append assign `((assign ,y ,ret)))
                  (append var `(,y))))))))

;; use list append
;;
(define (flat e)
  (match e
    [x #:when (or (symbol? x) (integer? x) (boolean? x))
       (values x '() '())]
    [`(let ([,x ,e]) ,body)
      (let-values
        ([(ret₁ assign₁ var₁) (flat e)]
         [(ret₂ assign₂ var₂) (flat body)])
        (values ret₂
                (append assign₁ `((assign ,x ,ret₁)) assign₂)  ;; always assign in let clause
                (append var₁ `(,x) var₂)))]
    [`(and ,e₁ ,e₂)
      (flat `(if ,e₁ ,e₂ #f))]
    [`(if ,condition ,then-clause ,else-clause)
      (let-values
        ([(ret_c assign_c var_c) ((malloc flat) condition)]
         [(ret_t assign_t var_t) (flat then-clause)]
         [(ret_e assign_e var_e) (flat else-clause)])
        (let ([y (gen-sym 'if)]
              [c (gen-sym 'cond)])
          (values y
            (append assign_c
              `((if (eq? #t ,ret_c)
                  ,(append assign_t `((assign ,y ,ret_t)))
                  ,(append assign_e `((assign ,y ,ret_e))))))
            (append* `(,y) var_c var_t var_e))))]
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

(define (flatten-R2 e)
  (flat e))
