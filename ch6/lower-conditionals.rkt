#lang racket

(require "../global.rkt")

(provide lower-conditionals-R4)


(define (lower-cond instr tail)
  (match instr
    [`(if (,cmp ,x ,y) ,thns ,elss)
      (cond
        [(and (null? thns) (null? elss)) tail]
        [(null? thns)
          (let ([endlabel (gen-sym 'if_end)])
            `((cmpq ,y ,x)
              (jmp-if ,(cc cmp) ,endlabel)
              ,@(foldr lower-cond '() elss)
              (label ,endlabel) .
              ,tail))]
        [(null? elss)
          (let ([endlabel (gen-sym 'if_end)])
            `((cmpq ,y ,x)
              (jmp-if ,(ncc cmp) ,endlabel)
              ,@(foldr lower-cond '() thns)
              (label ,endlabel) .
              ,tail))]
        [else
          (let ([thnlabel (gen-sym 'then)]
                [endlabel (gen-sym 'if_end)])
            `((cmpq ,y ,x)
              (jmp-if ,(cc cmp) ,thnlabel)
              ,@(foldr lower-cond '() elss)
              (jmp ,endlabel)
              (label ,thnlabel)
              ,@(foldr lower-cond '() thns)
              (label ,endlabel) .
              ,tail))])]
    [_ (cons instr tail)]))

(define (lower-conditionals-R4 p)
  (match p
    [`(define (,label) ,argc ,info ,instrs ...)
     `(define (,label) ,argc ,info
        ,@(foldr lower-cond '() instrs))]
    [`(program
        ,info ,type
        (defines ,ds ...)
        ,instrs ...)
     `(program
        ,info ,type
        (defines ,@(map lower-conditionals-R4 ds))
       ,@(foldr lower-cond '() instrs))]))
