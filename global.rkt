#lang racket

(provide func-pre temp-reg return-reg
         callee-save caller-save)

(define func-pre
  (if (eq? (system-type 'os) 'macosx)
    "_" ""))

(define temp-reg 'rax)
(define return-reg 'rax)

(define callee-save
  '(rcx rdx rsi rdi r8 r9 r10 r11))    ;; omit rax

(define caller-save
  '(rbx r12 r13 r14 r15))   ;; omit rsp rbp
