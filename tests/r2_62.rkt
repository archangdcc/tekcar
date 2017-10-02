(if
  (let ([x 2])
    (let ([y 1])
      (let ([z 0])
        (and
          (and
            (> x (read))
            (>= x 2))
          (and
            (eq? y 1)
            (and
              (< z y)
              (<= z y)))))))
  42
  777)
