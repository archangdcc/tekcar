#lang racket

(require "../global.rkt")

(provide patch-instructions-R4)


(define (patch-instr instr tail)
  (match instr
    [`(movq ,arg₁ ,arg₂)
      #:when (equal? arg₁ arg₂)
      tail]
    [`(cmpq ,arg (int ,int))
     `((movq (int ,int) (reg ,temp-reg))
       (cmpq ,arg (reg ,temp-reg)) . ,tail)]
    [`(leaq ,arg₁ ,arg₂)
      #:when (not (eq? (car arg₂) 'reg))
     `((leaq ,arg₁ (reg ,temp-reg))
       (movq (reg ,temp-reg) ,arg₂) . ,tail)]
    [`(,op ,arg₁ ,arg₂)
      #:when
      (and
        (pair? arg₁)
        (not (eq? (car arg₁) 'int))
        (not (eq? (car arg₁) 'reg))
        (not (eq? (car arg₁) 'byte-reg))
        (not (eq? (car arg₂) 'reg))
        (not (eq? (car arg₂) 'byte-reg)))
     `((movq ,arg₁ (reg ,temp-reg))
       (,op (reg ,temp-reg) ,arg₂) . ,tail)]
    [_ (cons instr tail)]))

(define (patch-instructions-R4 e)
  (match e
    [`(define (,label) ,argc ,info ,instrs ...)
     `(define (,label) ,argc ,info
        ,@(foldr patch-instr '() instrs))]
    [`(program
        ,info ,type
        (defines ,ds ...)
        ,instrs ...)
     `(program
        ,info ,type
        (defines ,@(map patch-instructions-R4 ds))
       ,@(foldr patch-instr '() instrs))]))
