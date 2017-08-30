#! /usr/bin/env racket
#lang racket

(require "utilities.rkt")
(require "interp.rkt")
(require "compiler.rkt")

;; (debug-level 1)

(interp-tests "integers and arithmetic" #f r0-passes interp-scheme "r0" (range 1 5))
(display "\e[0;34;42mr0-passes: tests passed!\e[0m") (newline)

(interp-tests "integers and variables" #f r1-passes interp-scheme "r1" (range 1 30))
(display "\e[0;34;42mr1-passes: interp tests passed!\e[0m") (newline)

(compiler-tests "integers and variables" #f r1-passes "r1" (range 1 30))
(display "\e[0;34;42mr1-final: compile tests passed!\e[0m") (newline)
