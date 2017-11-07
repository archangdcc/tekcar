#lang racket

(require "../utilities.rkt")
(require "../global.rkt")

(provide flatten-R6)


(define (malloc f)
  (lambda (e)
    (match e
      [`(has-type ,e ,t)
        (let-values ([(ret assign var) (f e)])
          (if (or (symbol? ret) (integer? ret) (boolean? ret))
            (values ret assign var)
            (let ([y (gen-sym 'tmp)])
              (values y
                (append assign `((assign ,y ,ret)))
                (append var `((,y . ,t)))))))])))


(define (flat-if condition thns elss)
  (match condition
    [`(has-type ,icondition Boolean)
      (match icondition
        [(? boolean?)
         (if icondition (flat thns) (flat elss))]
        [`(let ([,x ,e]) ,body)
          (flat `(let ([,x ,e]) (if ,body ,thns ,elss)))]
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
              (append var_c `((,y . ,(caddr thns))) var_t var_e))))]
        [`(and ,x ,y) (flat-if `(has-type (if ,x ,y (has-type #f Boolean)) Boolean) thns elss)]
        [`(not ,condition )
          (flat-if condition elss thns)]
        [`(,cmp ,a ,b)
          #:when(set-member? (set 'eq? '< '> '<= '>=) cmp)
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
                (append `((,y . ,(caddr thns))) var_a var_b var_t var_e))))]
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
               (append var_c `((,y . ,(caddr thns))) var_t var_e))))])]))

(define (adda arg)
  (match-let ([`(,v : ,t) arg])
    `(,v . ,t)))

(define (flat e)
  (match e
    [`(has-type ,e ,t) (flat e)]
    [`(function-ref ,label)
      (values e '() '())]
    [`(global-value ,name)
      (values e '() '())]
    [`(allocate ,n ,type)
      (values e '() '())]
    [`(collect ,n)
      (values '(void) `((collect ,n)) '())]
    [x #:when (or (symbol? x) (integer? x) (boolean? x))
      (values x '() '())]
    [`(let ([,x (has-type ,e ,t)]) ,body)
      (let-values
        ([(ret₁ assign₁ var₁) (flat e)]
         [(ret₂ assign₂ var₂) (flat body)])
        (values ret₂
          (append assign₁ `((assign ,x ,ret₁)) assign₂)  ;; always assign in let clause
          (append var₁ `((,x . ,t)) var₂)))]
    [`(and ,e₁ ,e₂)
      (flat `(if ,e₁ ,e₂ (has-type #f Boolean)))]
    [`(if ,condition ,thns ,elss)
      (flat-if condition thns elss)]
    [`(define (,fn ,args ...) : ,t ,e)
      (let-values
        ([(ret assign var) ((malloc flat) e)])    ;; only assign to non-arg in return
         (let ([vara (map adda args)])
        `(define (,fn ,@args) : ,t
           ,(append vara var)
           ,@(append assign `((return ,ret))))))]
    [`(program ,type ,ds ... ,e)
      (let-values ([(ret assign var) ((malloc flat) e)])    ;; only assign to non-arg in return
        `(program
           ,var ,type
           (defines ,@(map flat ds))
           ,@(append assign `((return ,ret)))))]
    [`(app (has-type (function-ref ,fn) ,t) ,es ...)
      (let-values
        ([(rets assigns vars) (map3 (malloc flat) es)])
        (values
          `(app (function-ref ,fn) . ,rets)
          (append* assigns)
          (append* vars)))]
    [`(inject ,e ,t)
      (let-values
        ([(ret assign var) ((malloc flat) e)])
        (values `(inject ,ret ,t) assign var))]
    [`(project ,e ,t)
      (let-values
        ([(ret assign var) ((malloc flat) e)])
        (values `(project ,ret ,t) assign var))]
    [`(,op ,es ...)
      (let-values
        ([(rets assigns vars) (map3 (malloc flat) es)])     ;; only assign to non-arg in op clause
        (values
          `(,op . ,rets)
          (append* assigns)
          (append* vars)))]))

(define (flatten-R6 e)
  (flat e))
