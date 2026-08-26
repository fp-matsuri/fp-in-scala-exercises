(ns fp-in-clojure.answers.laziness.lazy-seq
  (:refer-clojure :exclude [drop filter find map take take-while])
  (:require
   [clojure.core :as core]
   [clojure.spec.alpha :as s]))

;; NOTE: Clojureでは `lazy-seq` マクロを使って遅延シーケンスを生成することができる
;; ref. https://clojuredocs.org/clojure.core/lazy-seq
;; 例: '(1 2 3) に相当する遅延シーケンス
;;   (lazy-seq (cons 1 (lazy-seq (cons 2 (lazy-seq (cons 3 nil))))))

;; Exercise 5.1​ 遅延シーケンスを(非遅延)シーケンスに変換する関数 `->seq` を定義せよ。
;; NOTE​ Clojureでは遅延シーケンスが任意のシーケンス関数でそのまま扱えるため、敢えて非遅延シーケンスに変換する必要はない。
;; 生成過程で副作用を伴う遅延シーケンスを直ちに実体化する場合には `doall`, `dorun` 関数を使う。
;; ref. https://clojure.org/reference/sequences

(s/fdef ->seq-recursive
  :args (s/cat :coll seqable?)
  :ret seqable?)

(defn ->seq-recursive [coll]
  (if (seq coll)
    (cons (first coll)
          (->seq-recursive (rest coll)))
    ()))

(s/fdef ->seq
  :args (s/cat :coll seqable?)
  :ret seqable?)

(defn ->seq [coll]
  (loop [coll coll
         acc ()]
    (if (seq coll)
      (recur (rest coll)
             (cons (first coll) acc))
      (reverse acc))))

(s/fdef ->seq-fast
  :args (s/cat :coll seqable?)
  :ret seqable?)

(defn ->seq-fast [coll]
  (loop [coll coll
         buf (transient [])]
    (if (seq coll)
      (recur (rest coll)
             (conj! buf (first coll)))
      (persistent! buf))))

(s/fdef fold-right
  :args (s/cat :f ifn?
               :z any?
               :coll seqable?)
  :ret any?)

(defn fold-right [f z coll]
  (if (seq coll)
    ;; `f` の第2引数は0引数関数として受け取る
    (f (first coll) #(fold-right f z (rest coll)))
    z))

(s/fdef exists?
  :args (s/cat :p ifn?
               :coll seqable?)
  :ret boolean?)

(defn exists? [p coll]
  (fold-right (fn [x acc-fn] (or (p x) (acc-fn))) false coll))

(s/fdef find
  :args (s/cat :f ifn?
               :coll seqable?)
  :ret any?)

(defn find [f coll]
  (when-let [[x & xs] (seq coll)]
    (if (f x)
      x
      (recur f xs))))

;; Exercise 5.2: (遅延)シーケンスの先頭から最初の `n` 要素を返す関数 `take` 、先頭から最初の `n` 要素をスキップする関数 `drop` を定義せよ。

(s/fdef take
  :args (s/cat :n integer?
               :coll seqable?)
  :ret seqable?)

(defn take [n coll]
  (lazy-seq
   (when (and (pos? n)
              (seq coll))
     (cons (first coll)
           (take (dec n) (rest coll))))))

(s/fdef drop
  :args (s/cat :n integer?
               :coll seqable?)
  :ret seqable?)

(defn drop [n coll]
  (if (and (pos? n)
           (seq coll))
    (recur (dec n) (rest coll))
    coll))

;; Exercise 5.3: (遅延)シーケンスの先頭から条件を満たす限り続けて要素を返す関数 `take-while` を定義せよ。

(s/fdef take-while
  :args (s/cat :p ifn?
               :coll seqable?)
  :ret seqable?)

(defn take-while [p coll]
  (lazy-seq
   (when-let [[x & xs] (seq coll)]
     (when (p x)
       (cons x (take-while p xs))))))

;; Exercise 5.4: (遅延)シーケンスのすべての要素が条件を満たすかどうかを判定する関数 `for-all?` を定義せよ。

(s/fdef for-all?
  :args (s/cat :p ifn?
               :coll seqable?)
  :ret boolean?)

(defn for-all? [p coll]
  (fold-right (fn [x acc-fn] (and (p x) (acc-fn))) true coll))

;; Exercise 5.5: `fold-right` を用いて `take-while` を実装せよ。

(s/fdef take-while'
  :args (s/cat :p ifn?
               :coll seqable?)
  :ret seqable?)

(defn take-while' [p coll]
  (fold-right (fn [x acc-fn] (if (p x) (cons x (acc-fn)) ())) () coll))

;; Exercise 5.6: `fold-right` を用いて先頭要素を返す関数 `head-option` を実装せよ。

(s/fdef head-option
  :args (s/cat :coll seqable?)
  :ret any?)

(defn head-option [coll]
  (fold-right (fn [x _] x) nil coll))

;; Exercise 5.7: `fold-right` を用いて `map`, `filter`, `append`, `flat-map` を実装せよ。

(s/fdef map
  :args (s/cat :f ifn?
               :coll seqable?)
  :ret seqable?)

(defn map [f coll]
  (fold-right (fn [x acc-fn] (lazy-seq (cons (f x) (acc-fn)))) () coll))

(s/fdef filter
  :args (s/cat :p ifn?
               :coll seqable?)
  :ret seqable?)

(defn filter [p coll]
  (fold-right (fn [x acc-fn] (lazy-seq (if (p x) (cons x (acc-fn)) (acc-fn)))) () coll))

(s/fdef append
  :args (s/cat :coll1 seqable?
               :coll2 seqable?)
  :ret seqable?)

(defn append [coll1 coll2]
  (fold-right (fn [x acc-fn] (lazy-seq (cons x (acc-fn)))) coll2 coll1))

(s/fdef flat-map
  :args (s/cat :f ifn?
               :coll seqable?)
  :ret seqable?)

(defn flat-map [f coll]
  (fold-right (fn [x acc-fn] (lazy-seq (append (f x) (acc-fn)))) () coll))

(s/fdef ones
  :args (s/cat)
  :ret seqable?)

(defn ones []
  (lazy-seq (cons 1 (ones))))

;; Exercise 5.8: 任意の値を無限に繰り返す遅延シーケンスを生成する関数 `continually` を定義せよ。

(s/fdef continually
  :args (s/cat :x any?)
  :ret seqable?)

(defn continually [x]
  (lazy-seq (cons x (continually x))))

;; Exercise 5.9: `n` から1ずつ増える無限の遅延シーケンスを生成する関数 `from` を定義せよ。

(s/fdef from
  :args (s/cat :n integer?)
  :ret seqable?)

(defn from [n]
  (lazy-seq (cons n (from (inc n)))))

;; Exercise 5.10: フィボナッチ数の無限の遅延シーケンスを生成する関数 `fibs` を定義せよ。

(s/fdef fibs
  :args (s/cat)
  :ret seqable?)

(defn fibs []
  (letfn [(go [current next]
              (lazy-seq (cons current
                              (go next (+' current next)))))]
    (go 0 1)))

;; Exercise 5.11: は初期状態 `state` 、状態から次の要素と次の状態を返す関数 `f` を受け取って遅延シーケンスを生成する一般的な関数 `unfold` を定義せよ。

;; Scala風の型表記: `unfold: (f: S => Nilable[(A, S)], state: S) => LazySequence[A]`
(s/fdef unfold
  :args (s/cat :f ifn?
               :state any?)
  :ret seqable?)

(defn unfold [f state]
  (lazy-seq
   (when-let [[head next-state] (f state)]
     (cons head (unfold f next-state)))))

;; Exercise 5.12: `unfold` を用いて `fibs`, `from`, `continually`, `ones` を実装せよ。

(s/fdef fibs-via-unfold
  :args (s/cat)
  :ret seqable?)

(defn fibs-via-unfold []
  (unfold (fn [[current next]] [current [next (+' current next)]]) [0 1]))

(s/fdef from-via-unfold
  :args (s/cat :n integer?)
  :ret seqable?)

(defn from-via-unfold [n]
  (unfold (fn [x] [x (inc x)]) n))

(s/fdef continually-via-unfold
  :args (s/cat :x any?)
  :ret seqable?)

(defn continually-via-unfold [x]
  (unfold (fn [_] [x nil]) nil))

(s/fdef ones-via-unfold
  :args (s/cat)
  :ret seqable?)

(defn ones-via-unfold []
  (unfold (fn [_] [1 nil]) nil))

;; Exercise 5.13: `unfold` を用いて `map`, `take`, `take-while`, `zip-with`, `zip-all` を実装せよ。
;; `zip-all` は2つの(遅延)シーケンスが両方とも尽きるまでそれぞれ先頭から順に取り出して対応する要素をペアにして返す。

(s/fdef map-via-unfold
  :args (s/cat :f ifn?
               :coll seqable?)
  :ret seqable?)

(defn map-via-unfold [f coll]
  (unfold (fn [coll]
            (when-let [[x & xs] (seq coll)]
              [(f x) xs]))
          coll))

(s/fdef take-via-unfold
  :args (s/cat :n integer?
               :coll seqable?)
  :ret seqable?)

(defn take-via-unfold [n coll]
  (unfold (fn [[n coll]]
            (when (and (pos? n)
                       (seq coll))
              [(first coll) [(dec n) (rest coll)]]))
          [n coll]))

(s/fdef take-while-via-unfold
  :args (s/cat :p ifn?
               :coll seqable?)
  :ret seqable?)

(defn take-while-via-unfold [p coll]
  (unfold (fn [coll]
            (when-let [[x & xs] (seq coll)]
              (when (p x)
                [x xs])))
          coll))

;; Scala風の型表記: `zip-with: (f: (A, B) => C, coll1: LazySequence[A], coll2: LazySequence[B]) => LazySequence[C]`
(s/fdef zip-with
  :args (s/cat :f ifn?
               :coll1 seqable?
               :coll2 seqable?)
  :ret seqable?)

(defn zip-with [f coll1 coll2]
  (unfold (fn [[[x & xs :as coll1] [y & ys :as coll2]]]
            (when (and (seq coll1)
                       (seq coll2))
              [(f x y) [xs ys]]))
          [coll1 coll2]))

;; `zip-with` の特殊ケース

(s/fdef zip
  :args (s/cat :coll1 seqable?
               :coll2 seqable?)
  :ret seqable?)

(defn zip [coll1 coll2]
  (zip-with vector coll1 coll2))

;; Scala風の型表記: `zip-all: (coll1: LazySequence[A], coll2: LazySequence[B]) => LazySequence[(Nilable[A], Nilable[B])]`
(s/fdef zip-all
  :args (s/cat :coll1 seqable?
               :coll2 seqable?)
  :ret seqable?)

(defn zip-all [coll1 coll2]
  (unfold (fn [[[x & xs :as coll1] [y & ys :as coll2]]]
            (when (or (seq coll1)
                      (seq coll2))
              [[x y] [xs ys]]))
          [coll1 coll2]))

(s/fdef zip-with-all
  :args (s/cat :f ifn?
               :coll1 seqable?
               :coll2 seqable?)
  :ret seqable?)

(defn zip-with-all [f coll1 coll2]
  (unfold (fn [[[x & xs :as coll1] [y & ys :as coll2]]]
            (when (or (seq coll1)
                      (seq coll2))
              [(f x y) [xs ys]]))
          [coll1 coll2]))

;; `zip-with-all` の特殊ケース

(s/fdef zip-all-via-zip-with-all
  :args (s/cat :coll1 seqable?
               :coll2 seqable?)
  :ret seqable?)

(defn zip-all-via-zip-with-all [coll1 coll2]
  (zip-with-all vector coll1 coll2))

;; Exercise 5.14: 定義済みの関数を用いて(遅延)シーケンスが `prefix` で始まるかどうか判定する関数 `starts-with?` を定義せよ。

(s/fdef starts-with?
  :args (s/cat :prefix seqable?
               :coll seqable?)
  :ret boolean?)

(defn starts-with? [prefix coll]
  (->> (zip-all prefix coll)
       (take-while (comp some? first))
       (for-all? #(= (first %) (second %)))))

;; Exercise 5.15: `unfold` を用いて(遅延)シーケンスに `tail` を繰り返し適用した結果を返す関数 `tails` を定義せよ。
;; 例えば `(tails '(1 2 3))` は `((1 2 3) (2 3) (3) ())` を返す。

(s/fdef tails
  :args (s/cat :coll seqable?)
  :ret seqable?)

(defn tails [coll]
  (lazy-seq
   (append (unfold (fn [coll]
                     (when-let [[x & xs] (seq coll)]
                       [(cons x xs) xs]))
                   coll)
           (cons () nil))))

(s/fdef has-subsequence?
  :args (s/cat :sub seqable?
               :sup seqable?)
  :ret boolean?)

(defn has-subsequence? [sub sup]
  (exists? (partial starts-with? sub)
           (tails sup)))

;; Exercise 5.16: `tails` を一般化して、 `fold-right` の累積値を要素とする遅延シーケンスを返す関数 `scan-right` を定義せよ。

;; Scala風の型表記: `scan-right: (f: (A, B) => B, init: B, coll: LazySequence[A]) => LazySequence[B]`
(s/fdef scan-right
  :args (s/cat :f ifn?
               :init any?
               :coll seqable?)
  :ret seqable?)

(defn scan-right [f init coll]
  (->> coll
       (fold-right (fn [x acc]
                     (let [acc' (acc)
                           y (f x (first acc'))]
                       [y (cons y (second acc'))]))
                   [init (cons init nil)])
       second))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (->seq (lazy-seq (cons 1 (lazy-seq (cons 2 (lazy-seq (cons 3 nil)))))))
  (->seq [1 2 3])
  (->seq (range 10))
  (->seq ())
  (->seq nil)

  (fold-right (fn [x acc-fn] (+ x (acc-fn))) 0 (range (inc 10)))
  (fold-right (fn [x acc-fn] (+ x (acc-fn))) 0 [1 2 3])
  (fold-right (fn [x acc-fn] (+ x (acc-fn))) 0 ())
  (fold-right (fn [x acc-fn] (+ x (acc-fn))) 0 nil)

  (exists? even? (range))
  (exists? even? [1 3 5])
  (exists? even? [1 4 5])
  (exists? even? ())
  (exists? even? nil)

  (find #(> % 10) (range))
  (find #(> % 10) [1 2 3])
  (find #(> % 10) [9 10 11])
  (find #(> % 10) ())
  (find #(> % 10) nil)

  (take 10 (range))
  (take 10 ())
  (take 10 nil)

  (->> (range) (drop 10) (take 10))
  (->> () (drop 10) (take 10))
  (->> nil (drop 10) (take 10))

  (take-while #(< % 10) (range))
  (take-while #(< % 10) ())
  (take-while #(< % 10) nil)

  (for-all? even? (range))
  (for-all? even? [2 4 6])
  (for-all? even? [2 5 6])
  (for-all? even? ())
  (for-all? even? nil)

  (take-while' #(< % 10) (range))
  (take-while' #(< % 10) ())
  (take-while' #(< % 10) nil)

  (head-option (range))
  (head-option ())
  (head-option nil)

  (->> (range) (map #(* % %)) (core/take 10))

  (->> (range) (filter even?) (core/take 10))

  (core/take 10 (append [100 200 300] (range)))
  (core/take 10 (append (range) [100 200 300]))

  (->> (range) (flat-map #(repeat % %)) (core/take 10))

  (core/take 10 (ones))

  (core/take 10 (continually 42))

  (core/take 10 (from 5))

  (core/take 10 (fibs))
  (nth (fibs) 10000)

  (core/take 10 (unfold (fn [s] [s s]) 42))

  (core/take 10 (fibs-via-unfold))

  (core/take 10 (from-via-unfold 5))

  (core/take 10 (continually-via-unfold 42))

  (core/take 10 (ones-via-unfold))

  (->> (range) (map-via-unfold #(* % %)) (core/take 10))

  (take-via-unfold 10 (range))

  (take-while-via-unfold #(< % 10) (range))

  (core/take 10 (zip-with + [100 200 300] (range)))
  (core/take 10 (zip-with + (range) [100 200 300]))

  (core/take 10 (zip-all [100 200 300] (range)))
  (core/take 10 (zip-all (range) [100 200 300]))

  (starts-with? [0 1 2] (range))
  (starts-with? [0 1 4] (range))
  (starts-with? [] (range))

  (tails [1 2 3])
  (tails (range 10))
  (tails [])

  (has-subsequence? [0 1] (range))
  (has-subsequence? [2 3] (range))
  (has-subsequence? [1 3] (range))
  (has-subsequence? [] (range))

  (scan-right cons () (range 10))
  (scan-right + 0 (range (inc 10)))
  )
