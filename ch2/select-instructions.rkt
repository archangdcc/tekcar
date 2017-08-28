#lang racket

(provide select-instructions)

(define (select-instructions e)
  (match e
    ['() '()]
    [`((assign ,lhs (read)) . ,instr)
     `((callq read_int)
       (movq (reg rax) (var ,lhs)) .
       ,(select-instructions instr))]
    [`((assign ,x ,n) . ,instr) #:when (integer? n)
     `((movq (int ,n) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x ,y) . ,instr) #:when (symbol? y)
     `((movq (var ,y) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (- ,x)) . ,instr)
     `((negq (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (- ,n)) . ,instr) #:when (integer? n)
     `((movq (int ,n) (var ,x))
       (negq (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (- ,y)) . ,instr)
     `((movq (var ,y) (var ,x))
       (negq (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,n ,x)) . ,instr) #:when (integer? n)
     `((addq (int ,n) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,y ,x)) . ,instr)
     `((addq (var ,y) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,x ,n)) . ,instr) #:when (integer? n)
     `((addq (int ,n) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,x ,y)) . ,instr)
     `((addq (var ,y) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,m ,n)) . ,instr) #:when (and (integer? m) (integer? n))
     `((movq (int ,m) (var ,x))
       (addq (int ,n) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,m ,y)) . ,instr) #:when (integer? m)
     `((movq (int ,m) (var ,x))
       (addq (var ,y) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,y ,n)) . ,instr) #:when (integer? n)
     `((movq (int ,n) (var ,x))
       (addq (var ,y) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,y ,z)) . ,instr)
     `((movq (var ,y) (var ,x))
       (addq (var ,z) (var ,x)) .
       ,(select-instructions instr))]
    [`((return ,n) . ,instr) #:when (integer? n)
     `((movq (int ,n) (reg rax)) .
       ,(select-instructions instr))]
    [`((return ,x) . ,instr)
     `((movq (var ,x) (reg rax)) .
       ,(select-instructions instr))]
    [`(program ,var . ,instr)
     `(program ,var . ,(select-instructions instr))]))
