#lang racket

;; answer to exercise 1

(require racket/fixnum)
(provide pe)

;;(define (pe-neg r)
;;  (cond
;;    [(fixnum? r) (fx- 0 r)]
;;    [else `(-, r)]))
;;
;;(define (pe-add r₁ r₂)
;;  (cond
;;    [(and (fixnum? r₁) (fixnum? r₂)) (fx+ r₁ r₂)]
;;    [else `(+ ,r₁ ,r₂)]))
;;
;;(define (pe-arith e)
;;  (match e
;;    [(? fixnum?) e]
;;    [`(read) `(read)]
;;    [`(- ,(app pe-arith r)) (pe-neg r)]
;;    [`(+ ,(app pe-arith r₁) ,(app pe-arith r₂)) (pe-add r₁ r₂)]))
;;
;;(define (pe p)
;;  (match p
;;    [`(program ,e) `(program ,(pe-arith e))]))

;; R0:
;; exp ::= int | (read) | (- exp) | (+ exp exp)
;; R0':
;; exp ::= (read) | (- (read)) | (+ exp exp)
;; res ::= int | (+ int exp) | exp
(define (pe-neg r)
  (match r
    [(? fixnum?) (fx- 0 r)]
    [`(+ ,n ,e) #:when (fixnum? n) `(+ ,(fx- 0 n) ,(pe-neg e))]
    ['(read) '(- (read))]
    ['(- (read)) '(read)]
    [`(+ ,e₁ ,e₂) `(+ ,(pe-neg e₁) ,(pe-neg e₂))]))

(define (pe-add r₁ r₂)
  (match* (r₁ r₂)
    [((? fixnum?) (? fixnum?)) (fx+ r₁ r₂)]
    [((? fixnum?) `(+ ,n ,e)) #:when (fixnum? n) `(+ ,(fx+ r₁ n) ,e)]
    [((? fixnum?) _) `(+ ,r₁ ,r₂)]
    [(_ (? fixnum?)) (pe-add r₂ r₁)]
    [(`(+ ,a₁ ,b₁) `(+ ,a₂ ,b₂)) `(+ ,(pe-add a₁ a₂) ,(pe-add b₁ b₂))]
    [(`(+ ,n ,e₁) _) #:when (fixnum? n) `(+ ,n (+ ,e₁ ,r₂))]
    [(_ `(+ ,n ,e₂)) #:when (fixnum? n) `(+ ,n (+ ,r₁ ,e₂))]
    [(_ _) `(+ ,r₁ ,r₂)]))

(define (pe-arith e)
  (match e
    [(? fixnum?) e]
    [`(read) `(read)]
    [`(- ,(app pe-arith r)) (pe-neg r)]
    [`(+ ,(app pe-arith r₁) ,(app pe-arith r₂)) (pe-add r₁ r₂)]))

(define (pe p)
  (match p
    [`(program ,e) `(program ,(pe-arith e))]))


;; test
;(pe '(program (+ 1 (+ 2 (- 3)))))
;(pe '(program (+ 1 (+ 2 (read)))))
;(pe '(program (+ 1 (+ (read) (+ 10 (+ (- (read)) (- 5)))))))
