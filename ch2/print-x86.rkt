#lang racket

(require "../global.rkt")

(provide print-x86)

(define (header n)
  (string-append
    "\t.globl\t"
    func-pre
    "main\n"
    func-pre
    "main:\n"
    "\tpushq\t%rbp\n"
    "\tmovq\t%rsp, %rbp\n"
      (if (equal? n 0)    ;; no extra space needed
    "\n"
      (format
    "\tsubq\t$~v, %rsp\n\n"
      (* (ceiling (/ n 2)) 16)))))

(define (footer n)
  (string-append
    "\n\n"
    "\tmovq\t%rax, %rdi\n"
    "\tcallq\t"
    func-pre
    "print_int\n"
      (if (equal? n 0)
    ""
      (format
    "\taddq\t$~v, %rsp\n"
      (* (ceiling (/ n 2)) 16)))
    "\tmovq\t$0, %rax\n"
    "\tpopq\t%rbp\n"
    "\tretq\n"))

(define (print-x86 e)
  (match e
    [`(int ,n) (format "$~v" n)]
    [`(reg ,reg) (format "%~a" reg)]
    [`(deref ,reg ,offset) (format "~v(%~a)" offset reg)]
    [`(callq ,label) (format "\tcallq\t~a~s" func-pre label)]
    [`(program ,n . ,instrs)
      (string-join
        (map print-x86 instrs) "\n"
        #:before-first (header n)
        #:after-last (footer n))]
    [`(,op ,es ...)
      (string-join
        (map print-x86 es) ", "
        #:before-first (format "\t~a\t" op))]))
