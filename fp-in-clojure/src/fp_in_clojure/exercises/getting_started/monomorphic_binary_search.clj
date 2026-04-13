(ns fp-in-clojure.exercises.getting-started.monomorphic-binary-search
  (:require
   [clojure.spec.alpha :as s]))

;; まずは `string?` に特化したfind-first。
;; 理想的には任意の `seqable?` な型に対して動作するように一般化できるだろう。

(s/fdef find-first
  :args (s/cat :ss (s/coll-of string?)
               :k string?)
  :ret int?)

(defn find-first [ss k]
  ;; シーケンスの最初の要素からループを開始する。
  (loop [n 0]
    (cond
      ;; `n` がシーケンスの終端を過ぎたら、
      ;; シーケンス中にそのキーは存在しないという意味で `-1` を返す。
      (>= n (count ss)) -1
      ;; `(nth ss n)` はシーケンス `ss` のn番目の要素を取り出す。
      ;; `n` の位置の要素がキーと等しければ、
      ;; シーケンスのそのインデックスに要素が現れるという意味で `n` を返す。
      (= (nth ss n) k) n
      :else (recur (inc n)))))  ; そうでなければ `n` をインクリメントして探索を続ける。

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (find-first ["b" "e" "a" "d" "c"] "b")

  (find-first ["b" "e" "a" "d" "c"] "d")

  (find-first ["b" "e" "a" "d" "c"] "c")

  (find-first ["b" "e" "a" "d" "c"] "f")

  (find-first [] "b")
  )
