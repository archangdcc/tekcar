#lang racket

(provide print-x86)

(define func-pre
  (if (eq? (system-type 'os) 'maxosx)
    "_" ""))

(define (header n)
  (string-append
    "\t.globl\t"
    func-pre
    "main\n"
    func-pre
    "main:\n"
    "\tpushq\t%rbp\n"
    "\tmovq\t%rsp, %rbp\n"
      (if (equal? n 16)    ;; no extra space needed
    "\n"
      (format
    "\tsubq\t$~v, %rsp\n\n" ;; 8 for return address
      (- n 16)))))         ;; and 8 for old rbp

(define (footer n)
  (string-append
    "\n\n"
    "\tmovq\t%rax, %rdi\n"
    "\tcallq\t"
    func-pre
    "print_int\n"
      (if (equal? n 16)
    ""
      (format
    "\taddq\t$~v, %rsp\n"
      (- n 16)))
    "\tmovq\t$0, %rax\n"
    "\tpopq\t%rbp\n"
    "\tretq\n"))

(define (print-x86 e)
  (match e
    [`(int ,n) (format "$~v" n)]
    [`(reg ,reg) (format "%~a" reg)]
    [`(deref ,reg ,offset) (format "~v(%~a)" offset reg)]
    [`(callq ,label) (format "\tcallq\t~a" label)]
    [`(program ,n . ,instrs)
      (string-join
        (map print-x86 instrs) "\n"
        #:before-first (header n)
        #:after-last (footer n))]
    [`(,op ,es ...)
      (string-join
        (map print-x86 es) ", "
        #:before-first (format "\t~a\t" op))]))
