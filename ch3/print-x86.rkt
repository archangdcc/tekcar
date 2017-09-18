#lang racket

(require "../global.rkt")

(provide print-x86-ch3)


(define (callee-handler iter ls template)
  (iter
    (lambda (reg str)
      (string-append str
        (format template reg))) ""
    ls))

(define (header used-callee used-stack)
  (string-append
    "\t.globl\t"
    func-pre
    "main\n"
    func-pre
    "main:\n"
    "\tpushq\t%rbp\n"
      (callee-handler foldl used-callee
    "\tpushq\t%~s\n"
       )
    "\tmovq\t%rsp, %rbp\n"
      (if (zero? used-stack)    ;; no extra space needed
    "\n"
      (format
    "\tsubq\t$~v, %rsp\n\n"
      (* (ceiling (/ used-stack 2)) 16)))))

(define (footer used-callee used-stack)
  (string-append
    "\n\n"
    "\tmovq\t%rax, %rdi\n"
    "\tcallq\t"
    func-pre
    "print_int\n"
      (if (zero? used-stack)
    ""
      (format
    "\taddq\t$~v, %rsp\n"
      (* (ceiling (/ used-stack 2)) 16)))
    "\tmovq\t$0, %rax\n"
      (callee-handler foldr used-callee
    "\tpopq\t%~s\n"
       )
    "\tpopq\t%rbp\n"
    "\tretq\n"))

(define (print-x86-ch3 e)
  (match e
    [`(int ,n) (format "$~v" n)]
    [`(reg ,reg) (format "%~a" reg)]
    [`(deref ,reg ,offset) (format "~v(%~a)" offset reg)]
    [`(callq ,label) (format "\tcallq\t~a~s" func-pre label)]
    [`(program (,used-callee ,used-stack) . ,instrs)
      (string-join
        (map print-x86-ch3 instrs) "\n"
        #:before-first (header used-callee used-stack)
        #:after-last (footer used-callee used-stack))]
    [`(,op ,es ...)
      (string-join
        (map print-x86-ch3 es) ", "
        #:before-first (format "\t~a\t" op))]))
