#! /usr/bin/env racket
#lang racket

(require "utilities.rkt")
(require "interp.rkt")
(require "compiler.rkt")

(require "ch4/typecheck.rkt")


;(debug-level 0)
;(interp-tests "integers and arithmetic" #f r0-passes interp-scheme "r0" (range 1 5))
;(display "\e[0;34;42mr0-passes: tests passed!\e[0m") (newline)
;
;
;(debug-level 0)
;(interp-tests "integers and variables" #f r1-passes interp-scheme "r1" (range 1 32))
;(display "\e[0;34;42mr1-passes: interp tests passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "integers and variables" #f r1-passes "r1" (range 1 32))
;(newline) (display "\e[0;34;42mr1-final: compile tests passed!\e[0m") (newline)
;
;
;(debug-level 0)
;(interp-tests "register allocation" #f r1-passes-ch3 interp-scheme "r1" (range 1 32))
;(display "\e[0;34;42mr1-passes-ch3: interp tests passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "register allocation" #f r1-passes-ch3 "r1" (range 1 32))
;(newline) (display "\e[0;34;42mr1-passes-ch3-final: compile tests passed!\e[0m") (newline)


(debug-level 2)
(interp-tests "control flow" typecheck-R2 r2-passes interp-scheme "r2" (range 1 24))
(display "\e[0;34;42mcontrol flow passed!\e[0m") (newline)
;(debug-level 0)
;(compiler-tests "control flow" typecheck-R2 r2-passes "r2" (range 1 32))
;(newline) (display "\e[0;34;42mr1-passes-ch3-final: compile tests passed!\e[0m") (newline)
