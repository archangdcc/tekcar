#lang racket

(provide func-pre init-sym gen-sym
         temp-reg return-reg vec-reg rstk-reg
         callee-regs caller-regs
         caller-num reg-num
         color->reg reg->color
         cc)

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
(define vec-reg 'r11)
(define rstk-reg 'r15) ;; root stack

;; these are already define in utilities as caller/ee-save
;; but as sets.
(define caller-regs
  '(rcx rdx rsi rdi r8 r9 r10 r11))    ;; omit rax
(define callee-regs
  '(rbx r12 r13 r14 r15))   ;; omit rsp rbp
(define all-regs
  (append caller-regs callee-regs))
(define caller-num
  (length caller-regs))
(define reg-num
  (length all-regs))
(define (color->reg color)
  (list-ref all-regs color))
(define (reg->color reg)
  (index-of all-regs reg))

(define (cc cmp)
  (match cmp
    ['< 'l]
    ['> 'g]
    ['eq? 'e]
    ['<= 'le]
    ['>= 'ge]))
