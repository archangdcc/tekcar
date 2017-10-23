#lang racket

(require "../global.rkt")

(require "../utilities.rkt")

(provide print-x86-R4)


(define (callee-handler iter ls template)
  (iter
    (lambda (reg str)
      (string-append str
        (format template reg))) ""
    ls))

(define (header label used-callee used-stk used-rstk)
  (let
    ([f (if (eq? label 'main)
          (label-name label)
          (symbol->string label))])
    (string-append
      "\t.globl\t" f "\n"
      f ":\n"
      "\tpushq\t%rbp\n"
      (callee-handler foldl used-callee
        "\tpushq\t%~a\n")
      "\tmovq\t%rsp, %rbp\n"
      (if (zero? used-stk)    ;; no extra space needed
        ""
        (format
          "\tsubq\t$~a, %rsp\n"
          (* (ceiling (/ used-stk 2)) 16)))
      (if (eq? label 'main)
        (string-append
          (format "\tmovq\t$~a, %rdi\n" rstk-size)
          (format "\tmovq\t$~a, %rsi\n" heap-size)
          "\tcallq\t" (label-name "initialize") "\n"
          "\tmovq\t" (label-name "rootstack_begin")"(%rip), %r15\n")
        "")
      "\n")))

(define (footer used-callee used-stk used-rstk type)
  (string-append
    "\n\n"
    (if type
      (string-append
        (print-by-type (cadr type)) "\n"
        "\tmovq\t$0, %rax\n")
      "")
    (if (zero? used-rstk)
      ""
      (format
        "\tsubq\t$~a, %r15\n"
        (* used-rstk 8)))
    (if (zero? used-stk)
      ""
      (format
        "\taddq\t$~a, %rsp\n"
        (* (ceiling (/ used-stk 2)) 16)))
    (callee-handler foldr used-callee
      "\tpopq\t%~a\n")
    "\tpopq\t%rbp\n"
    "\tretq\n"))

(define (print-x86 e)
  (match e
    [`(int ,n) (format "$~a" n)]
    [`(reg ,reg) (format "%~a" reg)]
    [`(byte-reg ,reg) (format "%~a" reg)]
    [`(global-value ,name)
      (format "~a(%rip)" (label-name name))]
    [`(deref ,reg ,offset) (format "~a(%~a)" offset reg)]
    [`(stack-arg ,n) (format "~a(%rsp)" n)]
    [`(set ,cc ,e)
      (format "\tset~a\t~a" cc (print-x86 e))]
    [`(jmp-if ,cc ,label) (format "\tj~a\t~a" cc label)]
    [`(jmp ,label) (format "\tjmp\t~a" label)]
    [`(indirect-callq ,e) (format "\tcallq\t*~a" (print-x86 e))]
    [`(callq ,label) (format "\tcallq\t~a" (label-name label))]
    [`(label ,label) (format "~a:" label)]
    [`(function-ref ,label) (format "~a(%rip)" label)]
    [`(,op (stack-arg ,n) ,e)
      (format "\t~a\t~a(%rbp), ~a" op (+ 16 n) (print-x86 e))]
    [`(,op ,es ...)
      (string-join
        (map print-x86 es) ", "
        #:before-first (format "\t~a\t" op))]))

(define (print-x86-R4 e)
  (match e
    [`(define (,label) ,argc
        (,used-callee ,used-stk ,used-rstk)
        ,instrs ...)
      (string-join
        (map print-x86 instrs) "\n"
        #:before-first (header label used-callee used-stk used-rstk)
        #:after-last (footer used-callee used-stk used-rstk #f))]
    [`(program
        (,used-callee ,used-stk ,used-rstk) ,type
        (defines ,ds ...)
        ,instrs ...)
      (string-append
        (string-join
          (map print-x86-R4 ds) "\n\n")
        "\n\n"
        (string-join
          (map print-x86 instrs) "\n"
          #:before-first (header 'main used-callee used-stk used-rstk)
          #:after-last (footer used-callee used-stk used-rstk type)))]))
