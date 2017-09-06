#lang racket

(provide func-pre temp-reg)

(define func-pre
  (if (eq? (system-type 'os) 'macosx)
    "_" ""))

(define temp-reg 'rax)
