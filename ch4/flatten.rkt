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

(define (flat-if condition thns elss)
  (match condition
    [(? boolean?)
     (if condition (flat thns) (flat elss))]
    [`(let ([,x ,e]) ,body)
      (let-values
        ([(ret_e assign_e var_e) (flat e)]
         [(ret_b assign_b var_b) (flat-if body thns elss)])
        (values ret_b
          (append assign_e `((assign ,x ,ret_e)) assign_b)
          (append var_e `(,x) var_b)))]
    [`(if ,condition ,ithns ,ielss)
      (let-values
        ([(ret_c assign_c var_c) (flat-if condition ithns ielss)]
         [(ret_t assign_t var_t) (flat thns)]
         [(ret_e assign_e var_e) (flat elss)])
       (let ([y (gen-sym 'if)])
        (values y
          (append assign_c
           `((if (eq? ,ret_c #t)
               ,(append assign_t `((assign ,y ,ret_t)))
               ,(append assign_e `((assign ,y ,ret_e))))))
          (append var_c `(,y) var_t var_e))))]
    [`(and ,x ,y) (flat-if `(if ,x ,y #f) thns elss)]
    [`(not ,condition)
      (flat-if condition elss thns)]
    [`(,cmp ,a ,b)
      (let-values
        ([(ret_a assign_a var_a) ((malloc flat) a)]
         [(ret_b assign_b var_b) ((malloc flat) b)]
         [(ret_t assign_t var_t) (flat thns)]
         [(ret_e assign_e var_e) (flat elss)])
        (let ([y (gen-sym 'if)])
          (values y
            (append assign_a assign_b
             `((if (,cmp ,ret_a ,ret_b)
                 ,(append assign_t `((assign ,y ,ret_t)))
                 ,(append assign_e `((assign ,y ,ret_e))))))
            (append `(,y) var_a var_b var_t var_e))))]
    [_
     (let-values
       ([(ret_c assign_c var_c) ((malloc flat) condition)]
        [(ret_t assign_t var_t) (flat thns)]
        [(ret_e assign_e var_e) (flat elss)])
       (let ([y (gen-sym 'if)])
         (values y
           (append assign_c
             `((if (eq? ,ret_c #t)
                 ,(append assign_t `((assign ,y ,ret_t)))
                 ,(append assign_e `((assign ,y ,ret_e))))))
           (append var_c `(,y) var_t var_e))))]))

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
    [`(if ,condition ,thns ,elss)
      (flat-if condition thns elss)]
    [`(program ,type ,e)
      (let-values ([(ret assign var) ((malloc flat) e)])    ;; only assign to non-arg in return
        `(program ,var ,type . ,(append assign `((return ,ret)))))]
    [`(,op ,es ...)
      (let-values
        ([(rets assigns vars) (map3 (malloc flat) es)])     ;; only assign to non-arg in op clause
        (values
          `(,op . ,rets)
          (append* assigns)
          (append* vars)))]))

(define (flatten-R2 e)
  (flat e))
