#lang racket

(require "../global.rkt")
(provide patch-instructions)

(define (patch-instructions e)
  (match e
    ['() '()]
    [`((,op (deref ,reg₁ ,offset₁) (deref ,reg₂ ,offset₂)) . ,instrs)
     `((movq (deref ,reg₁ ,offset₁) (reg ,temp-reg))
       (,op (reg ,temp-reg) (deref ,reg₂ ,offset₂)) .
       ,(patch-instructions instrs))]
    [`(,instr . ,instrs)
     `(,instr . ,(patch-instructions instrs))]
    [`(program ,n . ,instrs)
     `(program ,n . ,(patch-instructions instrs))]))
