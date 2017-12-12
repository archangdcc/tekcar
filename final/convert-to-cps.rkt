#lang racket

(require "../global.rkt")

(provide convert-to-cps)

(define (ctx-push ctx args)
  (foldr
    (lambda (arg ctx)
      (lambda (vs)
        ((cps
           (lambda (w)
             (ctx `(,@vs ,w))))
         arg)))
    ctx args))

(define (vector-cps n)
  (letrec
    ([args
       (lambda (n)
         (cond
           [(zero? n) '()]
           [else `(,(gen-sym 'v) . ,(args (- n 1)))]))]
     [k (gen-sym 'k)])
    (let ([args (args n)])
      `(lambda (,@args ,k) (,k (vector ,@args))))))

(define (vector-set!-cps)
  (let ([vec (gen-sym 'vec)]
        [idx (gen-sym 'idx)]
        [v (gen-sym 'v)]
        [k (gen-sym 'k)])
  `(lambda (,vec ,idx ,v ,k)
     (,k (vector-set! ,vec ,idx ,v)))))

(define (cps ctx)
  (lambda (e)
    (match e
      ['call/cc
       (let*
         ([f (gen-sym 'f)]
          [cc (gen-sym 'cc)]
          [w (gen-sym 'w)]
          [h (gen-sym 'h)])
         (ctx `(lambda (,f ,cc) (,f (lambda (,w ,h) (,cc ,w)) ,cc))))]
      [`(define (,fn ,args ...) ,e)
        (let ([k (gen-sym 'k)])
          `(define (,fn ,@args ,k) ,((cps (lambda (v) `(,k ,v))) e)))]
      [`(program ,ds ... ,e)
       `(program ,@(map (cps ctx) ds) ,((cps ctx) e))]
      [`(lambda ,args ,e)
        (let ([k (gen-sym 'k)])
          (ctx `(lambda (,@args ,k)
                  ,((cps (lambda (v) `(,k ,v))) e))))]
      [`(let ([,x ,e]) ,b)
        (let ([ctx*
                (lambda (v)
                  `(let ((,x ,v)) ,((cps ctx) b)))])
          ((cps ctx*) e))]
      [`(if ,c ,e₁ ,e₂)
        (let ([ctx*
                (lambda (v)
                  `(if ,v ,((cps ctx) e₁) ,((cps ctx) e₂))
                  )])
          ((cps ctx*) c))]
      [`(vector ,args ...)
        (let*
          ([vec* (vector-cps (length args))]
           [ctx*
             (lambda (vs)
               (let ([v (gen-sym 'v)])
                 (match (ctx v)
                   [`(,k ,v*) #:when (equal? v v*) `(,vec* ,@vs ,k)]
                   [b `(,vec* ,@vs (lambda (,v) ,b))])))])
          ((ctx-push ctx* args) '()))]
      [`(vector-set! ,args ...)
        (let*
          ([vst* (vector-set!-cps)]
           [ctx*
             (lambda (vs)
               (let ([v (gen-sym 'v)])
                 (match (ctx v)
                   [`(,k ,v*) #:when (equal? v v*) `(,vst* ,@vs ,k)]
                   [b `(,vst* ,@vs (lambda (,v) ,b))])))])
          ((ctx-push ctx* args) '()))]
      [`(,op ,args ...)
        #:when (set-member?
                 (set 'void 'read 'and 'not '+ '-
                      'eq? '< '> '<= '>= 'vector-ref) op)
        (let ([ctx* (lambda (vs) (ctx `(,op . ,vs)))])
          ((ctx-push ctx* args) '()))]
      [(? boolean?) (ctx e)]
      [(? fixnum?) (ctx e)]
      [(? symbol?) (ctx e)]
      [`(,args ...)
        (let
          ([ctx*
             (lambda (vs)
               (let ([v (gen-sym 'v)])
                 (match (ctx v)
                   [`(,k ,v*) #:when (equal? v v*) `(,@vs ,k)]
                   [b `(,@vs (lambda (,v) ,b))])))])
          ((ctx-push ctx* args) '()))])))

(define convert-to-cps
  (cps (lambda (v) v)))
