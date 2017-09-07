#lang racket

(provide func-pre temp-reg return-reg
         callee-regs caller-regs)

(define func-pre
  (if (eq? (system-type 'os) 'macosx)
    "_" ""))

(define temp-reg 'rax)
(define return-reg 'rax)

;; these are already define in utilities as caller/ee-save
;; but as sets.
(define callee-regs
  '(rcx rdx rsi rdi r8 r9 r10 r11))    ;; omit rax

(define caller-regs
  '(rbx r12 r13 r14 r15))   ;; omit rsp rbp
