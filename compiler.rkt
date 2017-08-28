#lang racket
(require racket/fixnum)
(require "interp.rkt")

(require "ch1/pe.rkt")
(require "ch2/uniquify.rkt")
(require "ch2/flatten.rkt")
(require "ch2/select-instructions.rkt")
(require "ch2/assign-homes.rkt")
(require "ch2/patch-instructions.rkt")
(require "ch2/print-x86.rkt")

;; This exports r0-passes, defined below, to users of this file.
(provide r0-passes)
(provide r1-passes)
(provide r1-final)

;; The following pass is just a silly pass that doesn't change anything important,
;; but is nevertheless an example of a pass. It flips the arguments of +. -Jeremy
(define (flipper e)
  (match e
    [(? fixnum?) e]
    [`(read) `(read)]
    [`(- ,e1) `(- ,(flipper e1))]
    [`(+ ,e1 ,e2) `(+ ,(flipper e2) ,(flipper e1))]
    [`(program ,e) `(program ,(flipper e))]
    ))


;; Next we have the partial evaluation pass described in the book.
(define (pe-neg r)
  (cond [(fixnum? r) (fx- 0 r)]
	[else `(- ,r)]))

(define (pe-add r1 r2)
  (cond [(and (fixnum? r1) (fixnum? r2)) (fx+ r1 r2)]
	[else `(+ ,r1 ,r2)]))

(define (pe-arith e)
  (match e
    [(? fixnum?) e]
    [`(read) `(read)]
    [`(- ,e1) (pe-neg (pe-arith e1))]
    [`(+ ,e1 ,e2) (pe-add (pe-arith e1) (pe-arith e2))]
    [`(program ,e) `(program ,(pe-arith e))]
    ))   

;; Define the passes to be used by interp-tests and the grader
;; Note that your compiler file (or whatever file provides your passes)
;; should be named "compiler.rkt"
(define r0-passes
  `( ("flipper" ,flipper ,interp-scheme)
     ("partial evaluator" ,pe-arith ,interp-scheme)
     ("improved partial evaluator" ,pe ,interp-scheme)
     ))

(define r1-passes
  `( ("uniquify" ,(uniquify '()) ,interp-scheme)
     ("flatten" ,flatten ,interp-C)
     ("select-instructions" ,select-instructions ,interp-x86)
     ("assign-homes" ,assign-homes ,interp-x86)
     ("patch-instructions" ,patch-instructions ,interp-x86)
     ))

(define r1-final
  `( ("uniquify" ,(uniquify '()) ,interp-scheme)
     ("flatten" ,flatten ,interp-C)
     ("select-instructions" ,select-instructions ,interp-x86)
     ("assign-homes" ,assign-homes ,interp-x86)
     ("patch-instructions" ,patch-instructions ,interp-x86)
     ("print-x86" ,print-x86 ,interp-x86)
     ))
