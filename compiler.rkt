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

(require "ch3/uncover-live.rkt")
(require "ch3/build-interference.rkt")
(require "ch3/build-move.rkt")
(require "ch3/allocate-registers.rkt")
(require "ch3/print-x86.rkt")

(require "ch4/uniquify.rkt")
(require "ch4/flatten.rkt")
(require "ch4/select-instructions.rkt")
(require "ch4/uncover-live.rkt")
(require "ch4/build-interference.rkt")
(require "ch4/build-move.rkt")
(require "ch4/allocate-registers.rkt")
(require "ch4/lower-conditionals.rkt")
(require "ch4/patch-instructions.rkt")
(require "ch4/print-x86.rkt")

(require "ch5/uniquify.rkt")
(require "ch5/expose-allocation.rkt")
(require "ch5/flatten.rkt")
(require "ch5/select-instructions.rkt")
(require "ch5/uncover-live.rkt")
(require "ch5/uncover-null.rkt")
(require "ch5/build-interference.rkt")
(require "ch5/build-move.rkt")
(require "ch5/allocate-registers.rkt")
(require "ch5/lower-conditionals.rkt")
(require "ch5/patch-instructions.rkt")
(require "ch5/print-x86.rkt")

(require "ch6/uniquify.rkt")
(require "ch6/reveal-functions.rkt")
(require "ch6/expose-allocation.rkt")
(require "ch6/flatten.rkt")
(require "ch6/select-instructions.rkt")
(require "ch6/uncover-live.rkt")
(require "ch6/uncover-null.rkt")
(require "ch6/build-interference.rkt")
(require "ch6/build-move.rkt")
(require "ch6/allocate-registers.rkt")
(require "ch6/lower-conditionals.rkt")
(require "ch6/patch-instructions.rkt")
(require "ch6/print-x86.rkt")

(require "ch7/uniquify.rkt")
(require "ch7/reveal-functions.rkt")
(require "ch7/convert-to-closures.rkt")

(require "ch8/cast-insert.rkt")
(require "ch8/typecheck.rkt")
(require "ch8/uniquify.rkt")
(require "ch8/reveal-functions.rkt")
(require "ch8/flatten.rkt")
(require "ch8/select-instructions.rkt")
(require "ch8/uncover-live.rkt")
(require "ch8/build-interference.rkt")
(require "ch8/build-move.rkt")
(require "ch8/allocate-registers.rkt")
(require "ch8/print-x86.rkt")

;; This exports r0-passes, defined below, to users of this file.
(provide r0-passes)
(provide r1-passes)
(provide r1-passes-ch3)
(provide r2-passes)
(provide r3-passes)
(provide r4-passes)
(provide r5-passes)
(provide r7-passes)

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
  `( ("uniquify" ,uniquify ,interp-scheme)
     ("flatten" ,flatten ,interp-C)
     ("select-instructions" ,select-instructions ,interp-x86)
     ("assign-homes" ,assign-homes ,interp-x86)
     ("patch-instructions" ,patch-instructions ,interp-x86)
     ("print-x86" ,print-x86 #f)
     ))

(define r1-passes-ch3
  `( ("uniquify" ,uniquify ,interp-scheme)
     ("flatten" ,flatten ,interp-C)
     ("select-instructions" ,select-instructions ,interp-x86)
     ("uncover-live" ,uncover-live ,interp-x86)
     ("build-interference" ,build-interference ,interp-x86)
     ("build-move" ,build-move ,interp-x86)
     ("allocate-registers" ,allocate-registers ,interp-x86)
     ("patch-instructions" ,patch-instructions ,interp-x86)
     ("print-x86-ch3" ,print-x86-ch3 #f)
     ))

(define r2-passes
  `( ("uniquify" ,uniquify-R2 ,interp-scheme)
     ("flatten" ,flatten-R2 ,interp-C)
     ("select-instructions" ,select-instructions-R2 ,interp-x86)
     ("uncover-live" ,uncover-live-R2 ,interp-x86)
     ("build-interference" ,build-interference-R2 ,interp-x86)
     ("build-move" ,build-move-R2 ,interp-x86)
     ("allocate-registers" ,allocate-registers-R2 ,interp-x86)
     ("lower-conditionals" ,lower-conditionals ,interp-x86)
     ("patch-instructions" ,patch-instructions-R2 ,interp-x86)
     ("print-x86" ,print-x86-R2 #f)
     ))

(define r3-passes
  `( ("uniquify" ,uniquify-R3 ,interp-scheme)
     ("expose-alloction" ,expose-allocation ,interp-scheme)
     ("flatten" ,flatten-R3 ,interp-C)
     ("select-instructions" ,select-instructions-R3 ,interp-x86)
     ("uncover-live" ,uncover-live-R3 ,interp-x86)
     ("uncover-null" ,uncover-null-R3 ,interp-x86)
     ("build-interference" ,build-interference-R3 ,interp-x86)
     ("build-move" ,build-move-R3 ,interp-x86)
     ("allocate-registers" ,allocate-registers-R3 ,interp-x86)
     ("lower-conditionals" ,lower-conditionals-R3 ,interp-x86)
     ("patch-instructions" ,patch-instructions-R3 ,interp-x86)
     ("print-x86" ,print-x86-R3 #f)
     ))

(define r4-passes
  `( ("uniquify" ,uniquify-R4 ,interp-scheme)
     ("reveal-functions" ,reveal-functions-R4 ,interp-F)
     ("expose-alloction" ,expose-allocation-R4 ,interp-F)
     ("flatten" ,flatten-R4 ,interp-C)
     ("select-instructions" ,select-instructions-R4 ,interp-x86)
     ("uncover-live" ,uncover-live-R4 ,interp-x86)
     ("uncover-null" ,uncover-null-R4 ,interp-x86)
     ("build-interference" ,build-interference-R4 ,interp-x86)
     ("build-move" ,build-move-R4 ,interp-x86)
     ("allocate-registers" ,allocate-registers-R4 ,interp-x86)
     ("lower-conditionals" ,lower-conditionals-R4 ,interp-x86)
     ("patch-instructions" ,patch-instructions-R4 ,interp-x86)
     ("print-x86" ,print-x86-R4 #f)
     ))

(define r5-passes
  `( ("uniquify" ,uniquify-R5 ,interp-scheme)
     ("reveal-functions" ,reveal-functions-R5 ,interp-F)
     ("convert-to-closures" ,convert-to-closures ,interp-F)
     ("expose-alloction" ,expose-allocation-R4 ,interp-F)
     ("flatten" ,flatten-R4 ,interp-C)
     ("select-instructions" ,select-instructions-R4 ,interp-x86)
     ("uncover-live" ,uncover-live-R4 ,interp-x86)
     ("uncover-null" ,uncover-null-R4 ,interp-x86)
     ("build-interference" ,build-interference-R4 ,interp-x86)
     ("build-move" ,build-move-R4 ,interp-x86)
     ("allocate-registers" ,allocate-registers-R4 ,interp-x86)
     ("lower-conditionals" ,lower-conditionals-R4 ,interp-x86)
     ("patch-instructions" ,patch-instructions-R4 ,interp-x86)
     ("print-x86" ,print-x86-R4 #f)
     ))

(define r7-passes
  `( ("cast-insert" ,cast-insert ,interp-scheme)
     ("typecheck" ,typecheck-R6 ,interp-scheme)
     ("uniquify" ,uniquify-R6 ,interp-scheme)
     ("reveal-functions" ,reveal-functions-R6 ,interp-F)
     ("convert-to-closures" ,convert-to-closures ,interp-F)
     ("expose-alloction" ,expose-allocation-R4 ,interp-F)
     ("flatten" ,flatten-R6 ,interp-C)
     ("select-instructions" ,select-instructions-R6 ,interp-x86)
     ("uncover-live" ,uncover-live-R6 ,interp-x86)
     ("uncover-null" ,uncover-null-R4 ,interp-x86)
     ("build-interference" ,build-interference-R6 ,interp-x86)
     ("build-move" ,build-move-R6 ,interp-x86)
     ("allocate-registers" ,allocate-registers-R6 ,interp-x86)
     ("lower-conditionals" ,lower-conditionals-R4 ,interp-x86)
     ("patch-instructions" ,patch-instructions-R4 ,interp-x86)
     ("print-x86" ,print-x86-R6 #f)
     ))
