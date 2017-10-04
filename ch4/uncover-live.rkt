#lang racket

(provide uncover-live-R2)

(define (vars arg)
  (match arg
    [`(var ,x) (set x)]
    [_ (set)]))

(define (vars-assort instr)  ;; return all-vars, w-vars, r-vars
  (match instr
    [`(movq ,x ,y)
      (let ([sx (vars x)]
            [sy (vars y)])
        (values (set-union sx sy) sy sx))]
    [`(cmpq ,x ,y)
      (let ([sx (vars x)]
            [sy (vars y)])
        (values (set-union sx sy) (set) (set-union sx sy)))]
    [`(callq ,label)
      (values (set) (set) (set))]
    [`(set ,cc ,x)    ;; x is always (byte-reg al)
      (values (set) (set) (set))]
    [`(movzbq ,x ,y)  ;; x is always (byte-reg al)
      (let ([sy (vars y)])
        (values sy sy (set)))]
    [`(,op ,x)        ;; negq
      (let ([sx (vars x)])
        (values sx sx sx))]
    [`(,op ,x ,y)     ;; addq xorq
      (let ([sx (vars x)]
            [sy (vars y)])
        (values (set-union sx sy) sy (set-union sx sy)))]))

(define (uncover-live-helper live-after instrs)
  ;; the car of the result should be ignored
  ;; because it is the live set before first instr
  (if (eq? instrs '()) (values `(,live-after) instrs)
    (let-values
      ([(cdr-live-after cdr-new-instrs)
        (uncover-live-helper live-after (cdr instrs))])
      (match (car instrs)
        [`(if (,cmp ,x ,y) ,thns ,elss)
         (let-values
           ([(thn-lives thn-instrs)
             (uncover-live-helper (car cdr-live-after) thns)]
            [(els-lives els-instrs)
             (uncover-live-helper (car cdr-live-after) elss)])
           (let ([sx (vars x)]
                 [sy (vars y)])
             (values
               (cons
                 (set-union
                   (car thn-lives)
                   (car els-lives)
                   sx sy)
                 cdr-live-after)
               (cons
                 `(if (,cmp ,x ,y)
                    ,thn-instrs ,(cdr thn-lives)
                    ,els-instrs ,(cdr els-lives))
                 cdr-new-instrs))))]
        [_
         (let-values
           ([(a-vars w-vars r-vars)
             (vars-assort (car instrs))])
           (values
             (cons
               (set-union
                 (set-subtract (car cdr-live-after) w-vars)
                 r-vars)
               cdr-live-after)
             (cons
               (car instrs)
               cdr-new-instrs)))]))))

(define (uncover-live-R2 e)
  (match e
    [`(program ,vars ,type . ,instrs)
      (let-values
        ([(live-after new-instrs)
          (uncover-live-helper (set) instrs)])
        `(program (,@vars ,(cdr live-after)) ,type . ,new-instrs))]))
