#lang racket

(require "../global.rkt")

(provide patch-instructions-R2)


(define (patch-instr instr tail)
  (match instr
    [`(movq (deref ,reg ,offset) (deref ,reg ,offset)) tail]
    [`(movq (reg ,reg) (reg ,reg)) tail]
    [`(,op (deref ,reg₁ ,offset₁) (deref ,reg₂ ,offset₂))
     `((movq (deref ,reg₁ ,offset₁) (reg ,temp-reg))
       (,op (reg ,temp-reg) (deref ,reg₂ ,offset₂)) . ,tail)]
    [`(cmpq ,arg (int ,int))
     `((movq (int ,int) (reg ,temp-reg))
       (cmpq ,arg (reg ,temp-reg)) . ,tail)]
    [_ (cons instr tail)]))

(define (patch-instructions-R2 e)
  (match e
    [`(program ,frame-size . ,instrs)
     `(program ,frame-size .
       ,(foldr patch-instr '() instrs))]))
