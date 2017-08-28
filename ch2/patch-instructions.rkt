#lang racket

(provide patch-instructions)

(define (patch-instructions e)
  (match e
    ['() '()]
    [`((,op (deref ,reg₁ ,offset₁) (deref ,reg₂ ,offset₂)) . ,instrs)
     `((movq (deref ,reg₁ ,offset₁) (reg rax))
       (,op (reg rax) (deref ,reg₂ ,offset₂)) .
       ,(patch-instructions instrs))]
    [`(,instr . ,instrs)
     `(,instr . ,(patch-instructions instrs))]
    [`(program ,n . ,instrs)
     `(program ,n . ,(patch-instructions instrs))]))
