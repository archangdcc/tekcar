(let ([x 31]) (let ([y (- 11)]) (+ (let z (let ([x (- y)]) x) z) (let ([y x]) y))))
