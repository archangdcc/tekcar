#lang racket

(provide select-instructions)

(define (select-instructions e)
  (match e
    [`,n #:when (integer? n)
     `(int ,n)]
    [`,x #:when (symbol? x)
     `(var ,x)]
    ['() '()]
    [`((assign ,lhs (read)) . ,instr)
     `((callq read_int)
       (movq (reg rax) (var ,lhs)) .
       ,(select-instructions instr))]
    [`((assign ,x (- ,x)) . ,instr)
     `((negq (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (- ,y)) . ,instr)
     `((movq ,(select-instructions y) (var ,x))
       (negq (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,y ,x)) . ,instr)
     `((addq ,(select-instructions y) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,x ,y)) . ,instr)
     `((addq ,(select-instructions y) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x (+ ,y ,z)) . ,instr)
     `((movq ,(select-instructions y) (var ,x))
       (addq ,(select-instructions z) (var ,x)) .
       ,(select-instructions instr))]
    [`((assign ,x ,y) . ,instr)
     `((movq ,(select-instructions y) (var ,x)) .
       ,(select-instructions instr))]
    [`((return ,y) . ,instr)
     `((movq ,(select-instructions y) (reg rax)) .
       ,(select-instructions instr))]
    [`(program ,var . ,instr)
     `(program ,var . ,(select-instructions instr))]))
