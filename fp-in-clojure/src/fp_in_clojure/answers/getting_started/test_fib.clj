(ns fp-in-clojure.answers.getting-started.test-fib
  (:require
   [fp-in-clojure.answers.getting-started.my-program :refer [fib]]))

;; `fib` に対するテストの実装
(defn -main [& _]
  (println "Expected: 0, 1, 1, 2, 3, 5, 8")
  (println (format "Actual:   %d, %d, %d, %d, %d, %d, %d"
                   (fib 0) (fib 1) (fib 2) (fib 3) (fib 4) (fib 5) (fib 6))))

(comment
  (with-out-str
    (-main))
  )
