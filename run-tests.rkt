#! /usr/bin/env racket
#lang racket

(require "utilities.rkt")
(require "interp.rkt")
(require "compiler.rkt")

(debug-level 1)

;;(interp-tests "integers and arithmetic" #f r0-passes interp-scheme "r0" (range 1 5))
;;(display "tests passed!") (newline)

;;(interp-tests "integers and variables" #f r1-passes interp-scheme "r1" (range 1 30))
;;(display "tests passed!") (newline)

(compiler-tests "integers and variables" #f r1-passes "r1" (range 1 30))
(display "tests passed!") (newline)
