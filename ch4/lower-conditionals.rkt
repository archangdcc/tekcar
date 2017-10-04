#lang racket

(require "../global.rkt")

(provide lower-conditionals)


(define (lower-cond instr tail)
  (match instr
    [`(if (,cmp ,x ,y) ,thns ,elss)
     (let ([thnlabel (gen-sym 'then)]
           [endlabel (gen-sym 'if_end)])
       `((cmpq ,y ,x)
         (jmp-if ,(cc cmp) ,thnlabel)
         ,@(foldr lower-cond '() elss)
         (jmp ,endlabel)
         (label ,thnlabel)
         ,@(foldr lower-cond '() thns)
         (label ,endlabel) .
         ,tail))]
    [_ (cons instr tail)]))

(define (lower-conditionals p)
  (match p
    [`(program ,info ,type . ,instrs)
     `(program ,info ,type .
       ,(foldr lower-cond '() instrs))]))
