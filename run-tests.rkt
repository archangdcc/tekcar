#! /usr/bin/env racket
#lang racket

(require "utilities.rkt")
(require "interp.rkt")
(require "compiler.rkt")

(require "ch4/typecheck.rkt")
(require "ch5/typecheck.rkt")
(require "ch6/typecheck.rkt")
(require "ch7/typecheck.rkt")


;(debug-level 0)
;(interp-tests "integers and arithmetic" #f r0-passes interp-scheme "r0" (range 1 5))
;(display "\e[0;34;42mr0-passes: tests passed!\e[0m") (newline)


;(debug-level 0)
;(interp-tests "integers and variables" #f r1-passes interp-scheme "r1" (range 1 32))
;(display "\e[0;34;42mr1-passes: interp tests passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "integers and variables" #f r1-passes "r1" (range 1 32))
;(newline) (display "\e[0;34;42mr1-final: compile tests passed!\e[0m") (newline)


;(debug-level 0)
;(interp-tests "register allocation" #f r1-passes-ch3 interp-scheme "r1" (range 1 32))
;(display "\e[0;34;42mr1-passes-ch3: interp tests passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "register allocation" #f r1-passes-ch3 "r1" (range 1 32))
;(newline) (display "\e[0;34;42mr1-passes-ch3-final: compile tests passed!\e[0m") (newline)


;(debug-level 2)
;(interp-tests "control flow" typecheck-R2 r2-passes interp-scheme "r2" (range 1 63))
;(display "\e[0;34;42mcontrol flow passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "control flow" typecheck-R3 r2-passes "r1" (range 1 32))
;(compiler-tests "control flow" typecheck-R2 r2-passes "r2" (range 1 63))
;(newline)
;(display "\e[0;34;42mcontrol flow: compile tests passed!\e[0m") (newline)


;(debug-level 2)
;(interp-tests "tuple & gc" typecheck-R3 r3-passes interp-scheme "r3" (range 1 36))
;(display "\e[0;34;42mtuple & gc passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "tuple & gc" typecheck-R3 r3-passes "r1" (range 1 32))
;(compiler-tests "tuple & gc" typecheck-R3 r3-passes "r2" (range 1 63))
;(compiler-tests "tuple & gc" typecheck-R3 r3-passes "r3" (range 1 36))
;(newline)
;(display "\e[0;34;42mtuple & gc: compile tests passed!\e[0m") (newline)

;(debug-level 2)
;(interp-tests "function" typecheck-R4 r4-passes interp-scheme "r2" (range 1 63))
;(interp-tests "function" typecheck-R4 r4-passes interp-scheme "r3" (range 1 36))
;(interp-tests "function" typecheck-R4 r4-passes interp-scheme "r4" (range 1 39))
;(display "\e[0;34;42mfunction passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "function" typecheck-R4 r4-passes "r1" (range 1 32))
;(compiler-tests "function" typecheck-R4 r4-passes "r2" (range 1 63))
;(compiler-tests "function" typecheck-R4 r4-passes "r3" (range 1 36))
;(compiler-tests "function" typecheck-R4 r4-passes "r4" (range 1 39))
;(newline)
;(display "\e[0;34;42mfunction: compile tests passed!\e[0m") (newline)


;(debug-level 2)
;(interp-tests "lambda" typecheck-R5 r5-passes interp-scheme "r5" (range 1 13))
;(display "\e[0;34;42mlambda passed!\e[0m") (newline)
(debug-level 0)
(compiler-tests "lambda" typecheck-R5 r5-passes "s1" (range 1 37))
(compiler-tests "lambda" typecheck-R5 r5-passes "s2" (range 1 21))
(compiler-tests "lambda" typecheck-R5 r5-passes "s3" (range 1 20))
(compiler-tests "lambda" typecheck-R5 r5-passes "s4" (range 1 8))
(compiler-tests "lambda" typecheck-R5 r5-passes "r1" (range 1 32))
(compiler-tests "lambda" typecheck-R5 r5-passes "r2" (range 1 63))
(compiler-tests "lambda" typecheck-R5 r5-passes "r3" (range 1 36))
(compiler-tests "lambda" typecheck-R5 r5-passes "r4" (range 1 39))
(compiler-tests "lambda" typecheck-R5 r5-passes "r5" (range 1 13))
(newline)
(display "\e[0;34;42mlambda: compile tests passed!\e[0m") (newline)
