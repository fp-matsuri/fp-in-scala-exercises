(ns fp-in-clojure.exercises.getting-started.format-abs-and-factorial
  (:require
   [fp-in-clojure.exercises.getting-started.my-program :refer [abs factorial format-result]]))

;; 一般化した `format-result` 関数を
;; `abs` と `factorial` の両方と一緒に利用することができる。
(defn -main [& _]
  (println (format-result "absolute value" -42 abs))
  (println (format-result "factorial" 7 factorial)))

(comment
  (with-out-str
    (-main))
  )
