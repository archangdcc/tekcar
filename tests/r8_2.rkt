(+ 1 (call/cc (lambda (k) (+ 1 (call/cc (lambda (h) (k 41)))))))
