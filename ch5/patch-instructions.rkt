#lang racket

(require "../global.rkt")

(provide patch-instructions-R3)


(define (patch-instr instr tail)
  (match instr
    [`(movq (deref ,reg ,offset) (deref ,reg ,offset)) tail]
    [`(movq (reg ,reg) (reg ,reg)) tail]
    [`(,op (deref ,reg₁ ,offset₁) (deref ,reg₂ ,offset₂))
     `((movq (deref ,reg₁ ,offset₁) (reg ,temp-reg))
       (,op (reg ,temp-reg) (deref ,reg₂ ,offset₂)) . ,tail)]
    [`(,op (deref ,reg ,offset) (global-value ,name))
     `((movq (deref ,reg ,offset) (reg ,temp-reg))
       (,op (reg ,temp-reg) (global-value ,name)) . ,tail)]
    [`(,op (global-value ,name) (deref ,reg ,offset))
     `((movq (global-value ,name) (reg ,temp-reg))
       (,op (reg ,temp-reg) (deref ,reg ,offset)) . ,tail)]
    [`(,op (global-value ,name₁) (global-value ,name₂))
     `((movq (global-value ,name₁) (reg ,temp-reg))
       (,op (reg ,temp-reg) (global-value ,name₂)) . ,tail)]
    [`(cmpq ,arg (int ,int))
     `((movq (int ,int) (reg ,temp-reg))
       (cmpq ,arg (reg ,temp-reg)) . ,tail)]
    [_ (cons instr tail)]))

(define (patch-instructions-R3 e)
  (match e
    [`(program ,info ,type . ,instrs)
     `(program ,info ,type .
       ,(foldr patch-instr '() instrs))]))
