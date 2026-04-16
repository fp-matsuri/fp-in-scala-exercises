;; 関数型プログラミング(FP)では関数を取り回すことがよくあるため、
;; 名前を付けること *なく* 関数を組み立てるシンタックスがあると便利だ
(ns fp-in-clojure.exercises.getting-started.anonymous-functions
  (:require
   [fp-in-clojure.exercises.getting-started.my-program :refer [abs factorial format-result]]))

;; 無名関数の例:
(defn -main [& _]
  (println (format-result "absolute value" -42 abs))
  (println (format-result "factorial" 7 factorial))
  (println (format-result "increment" 7 (fn [x] (inc x))))
  ;; NOTE: `#(f %)` や `#(g %1 %2 %3)` のように使える無名関数(ラムダ式)の略記法
  ;; ref. https://clojure.org/guides/weird_characters#_anonymous_function
  (println (format-result "increment2" 7 #(inc %)))
  (println (format-result "increment3" 7 inc))
  (println (format-result "increment4" 7 (fn [x] (let [r (inc x)] r)))))

(comment
  (with-out-str
    (-main))
  )
