#lang racket

(require "../global.rkt")
(provide patch-instructions)

(define (patch-instr instr tail)
  (match instr
    [`(,op (deref ,reg₁ ,offset₁) (deref ,reg₂ ,offset₂))
     `((movq (deref ,reg₁ ,offset₁) (reg ,temp-reg))
       (,op (reg ,temp-reg) (deref ,reg₂ ,offset₂)) . ,tail)]
    [_ (cons instr tail)]))

(define (patch-instructions e)
  (match e
    [`(program ,frame-size . ,instrs)
     `(program ,frame-size .
       ,(foldr patch-instr '() instrs))]))
