#lang racket

(require data/heap)

(provide make-sats add-sats mod-sats max-sats
         empty-sats? sats-has-key?
         make-frqs add-frqs max-frqs empty-frqs?
         func-pre init-sym gen-sym
         temp-reg return-reg vec-reg rstk-reg
         callee-regs caller-regs all-regs
         caller-num reg-num
         color->reg reg->color
         cc R4-ops)

(define sym-pool (void))
(define (init-sym)
  (set! sym-pool (make-hash)))
(define (gen-sym y)
  (let ([value (hash-ref! sym-pool y 0)])
   (hash-set! sym-pool y (+ 1 value))
   (string->symbol (format "~s.~s" y value))))

;; saturation hashtable and heap
(define (make-sats)
  (let
    ([sats-tbl (make-hash)]
     [sats-prq
       (make-heap
         (lambda (a b)
           (>= (cdr a) (cdr b))))])
    (cons sats-tbl sats-prq)))

(define (add-sats sats v sat)
  (match-let ([`(,sats-tbl . ,sats-prq) sats])
    (hash-set! sats-tbl v sat)
    (heap-add! sats-prq `(,v . ,(set-count sat)))))

(define (mod-sats sats v c)
  (match-let ([`(,sats-tbl . ,sats-prq) sats])
    (let ([sat (hash-ref sats-tbl v)])
      (if (set-member? sat c)
        (void)
        (let ([n (set-count sat)])
          (set-add! sat c)
          (heap-remove!
            sats-prq `(,v . ,n))
          (heap-add! sats-prq `(,v . ,(+ 1 n))))))))

(define (sats-has-key? sats v)
  (hash-has-key? (car sats) v))

(define (max-sats sats)
  (match-let ([`(,sats-tbl . ,sats-prq) sats])
    (let* ([hm (car (heap-min sats-prq))]
           [sat (hash-ref sats-tbl hm)])
      (hash-remove! sats-tbl hm)
      (heap-remove-min! sats-prq)
      (cons hm sat))))

(define (empty-sats? sats)
  (equal? (car sats) (make-hash)))

;; move-related color freq table and heap
(define (make-frqs)
  (let
    ([frqs-tbl (make-hash)]
     [frqs-prq
       (make-heap
         (lambda (a b)
           (>= (cdr a) (cdr b))))])
    (cons frqs-tbl frqs-prq)))

(define (add-frqs frqs c)
  (match-let ([`(,frqs-tbl . ,frqs-prq) frqs])
    (let ([frq (hash-ref frqs-tbl c 0)])
      (hash-set! frqs-tbl c (+ 1 frq))
      (heap-remove!
        frqs-prq `(,c . ,frq))
      (heap-add! frqs-prq `(,c . ,(+ 1 frq))))))

(define (max-frqs frqs)
  (match-let ([`(,frqs-tbl . ,frqs-prq) frqs])
    (car (heap-min frqs-prq))))

(define (empty-frqs? frqs)
  (equal? (car frqs) (make-hash)))



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
  '(rcx rdx rsi rdi r8 r9 r10))    ;; omit rax r11
(define callee-regs
  '(rbx r12 r13 r14))   ;; omit rsp rbp r15
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

(define R4-ops
  (set 'eq? '< '> '<= '>= '- '+
       'and 'not 'if 'read 'void
       'vector 'vector-ref 'vector-set!))

