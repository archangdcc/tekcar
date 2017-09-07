#lang racket

(provide func-pre init-sym gen-sym
         temp-reg return-reg callee-regs caller-regs)

(define sym-pool (void))
(define (init-sym)
  (set! sym-pool (make-hash)))
(define (gen-sym y)
  (let ([value (hash-ref! sym-pool y 0)])
   (hash-set! sym-pool y (+ 1 value))
   (string->symbol (format "~s.~s" y value))))

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
