#lang racket

(require "../global.rkt")

(provide print-x86-R3)


(define (callee-handler iter ls template)
  (iter
    (lambda (reg str)
      (string-append str
        (format template reg))) ""
    ls))

(define (printtype type)
  (match type
    [`(type ,T)
      (match T
        [`(Vector . ,ts) "print_vector"]
        ['Integer "print_int"]
        ['Void "print_void"]
        ['Boolean "print_bool"])]))

(define (header used-callee used-stk used-rstk)
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
      (if (zero? used-stk)    ;; no extra space needed
    "\n"
      (format
    "\tsubq\t$~v, %rsp\n"
      (* (ceiling (/ used-stk 2)) 16)))
    "\tmovq\t$16384, %rdi\n"
    "\tmovq\t$16, %rsi\n"
    "\tcallq\t" func-pre "initialize\n"
    "\tmovq\t" func-pre "rootstack_begin(%rip), %r15\n\n"
      ))

(define (footer used-callee used-stk used-rstk type)
  (string-append
    "\n\n"
    "\tmovq\t%rax, %rdi\n"
    "\tcallq\t"
    func-pre
    (printtype type)
    "\n"
      (if (zero? used-rstk)
    ""
      (format
    "\tsubq\t$~v, %r15\n"
      (* used-stk 8)))
      (if (zero? used-stk)
    ""
      (format
    "\taddq\t$~v, %rsp\n"
      (* (ceiling (/ used-stk 2)) 16)))
    "\tmovq\t$0, %rax\n"
      (callee-handler foldr used-callee
    "\tpopq\t%~s\n"
       )
    "\tpopq\t%rbp\n"
    "\tretq\n"))

(define (print-x86-R3 e)
  (match e
    [`(int ,n) (format "$~v" n)]
    [`(reg ,reg) (format "%~a" reg)]
    [`(byte-reg ,reg) (format "%~a" reg)]
    [`(global-value ,name)
      (format "~a~s(%rip)" func-pre name)]
    [`(set ,cc ,arg)
      (string-append
        (format "\tset~a\t" cc)
        (print-x86-R3 arg))]
    [`(jmp-if ,cc ,arg)
      (string-append
        (format "\tj~a\t" cc)
        (print-x86-R3 arg))]
    [`(deref ,reg ,offset) (format "~v(%~a)" offset reg)]
    [`(callq ,label) (format "\tcallq\t~a~s" func-pre label)]
    [`(program (,used-callee ,used-stk ,used-rstk) ,type . ,instrs)
      (string-join
        (map print-x86-R3 instrs) "\n"
        #:before-first (header used-callee used-stk used-rstk)
        #:after-last (footer used-callee used-stk used-rstk type))]
    [`(label ,label) (format "~a:" label)]
    [`(,op ,es ...)
      (string-join
        (map print-x86-R3 es) ", "
        #:before-first (format "\t~a\t" op))]
    [_ (format "~a" e)]))   ;; label
