(ns fp-in-clojure.exercises.data-structures.list
  (:refer-clojure :exclude [concat drop drop-while filter list list? map reverse])
  (:require
   [clojure.core.match :refer [match]]
   [clojure.spec.alpha :as s])
  (:import
   (clojure.lang
    ISeq
    Sequential)))

;; リストの非空値を表す `Cons` 型。
;; `head` は任意の値、`tail` は `nil` または `Cons` 。
;; NOTE: Clojureには代数的データ型を定義する構文はなく、ここではユーザー定義型として
;; `Cons` を定義して標準ライブラリのシーケンス(論理的なリストを表す抽象)と同様の
;; インターフェースを必要な範囲で実装している。
;; ref. https://clojure.org/reference/datatypes
;; ref. https://clojure.org/reference/sequences

(deftype Cons
  [head tail]
  ;; NOTE: この実装により標準ライブラリの first, rest, cons, seq などがそのまま動作する。
  ISeq
  (first [_] head)
  (next [_] tail)
  (more [_] tail)
  (cons [this o] (Cons. o this))
  (equiv [this o]
    (and (sequential? o)
         (= (first this) (first o))
         (= (next this) (next o))))
  (seq [this] this)
  Sequential)

;; `Cons` 判定のための述語関数。

(s/fdef cons?
  :args (s/cat :x any?)
  :ret boolean?)

(defn cons? [x]
  (and (instance? Cons x)
       (or (nil? (.-tail x))
           (cons? (.-tail x)))))

;; リスト判定のための述語関数。
;; リストは `nil` または `Cons` で構成される。

(s/fdef list?
  :args (s/cat :x any?)
  :ret boolean?)

(defn list? [x]
  (or (nil? x)
      (cons? x)))

(s/fdef list
  :args (s/cat :args (s/* any?))
  :ret list?)

(defn list [& args]  ; 可変長引数関数
  (if (empty? args)
    nil
    (Cons. (first args)
           (apply list (rest args)))))

(s/fdef sum
  :args (s/cat :ns (s/and list?
                          #(every? integer? %)))
  :ret integer?)

(defn sum [ns]
  (if (empty? ns)
    0  ; 空の整数リストの和は0
    (+ (first ns)
       (sum (rest ns)))))  ; 空でない整数リストの和は先頭要素に残りの要素の和を加えたもの

(s/fdef product
  :args (s/cat :ns (s/and list?
                          #(every? integer? %)))
  :ret integer?)

(defn product [ns]
  (cond
    (empty? ns) 1
    (zero? (first ns)) 0
    :else (* (first ns)
             (product (rest ns)))))

;; Exercise 3.1: 以下の式 `result `の評価結果は何になるか? (推測してからREPLで確認してみよう)

(def result
  ;; NOTE: ここではパターンマッチングの例示のため、準標準ライブラリcore.matchを利用している。
  ;; ref. https://github.com/clojure/core.match
  (match (list 1 2 3 4 5)
    ([x 2 4 & _] :seq) x
    nil 42
    ([x y 3 4 & _] :seq) (+ x y)
    ([h & t] :seq) (+ h (sum t))
    :else 101))

(s/fdef append
  :args (s/cat :a1 list?
               :a2 list?)
  :ret list?)

(defn append [a1 a2]
  (if (empty? a1)
    a2
    (Cons. (first a1)
           (append (rest a1) a2))))

(s/fdef fold-right
  :args (s/cat :f ifn?
               :acc any?
               :as list?)
  :ret any?)

(defn fold-right [f acc as]
  (if (empty? as)
    acc
    (f (first as)
       (fold-right f acc (rest as)))))

(s/fdef sum-via-fold-right
  :args (s/cat :ns (s/and list?
                          #(every? integer? %)))
  :ret integer?)

(defn sum-via-fold-right [ns]
  ;; NOTE: Clojureでは、記号演算子に見えるものもただの関数であり、
  ;; 高階関数に引数としてそのまま渡すことができる。
  (fold-right + 0 ns))

(s/fdef product-via-fold-right
  :args (s/cat :ns (s/and list?
                          #(every? integer? %)))
  :ret integer?)

(defn product-via-fold-right [ns]
  (fold-right * 1 ns))

;; Exercise 3.2: 先頭要素以外のリストを返す関数 `tail` を定義せよ。

(s/fdef tail
  :args (s/cat :l list?)
  :ret list?)

(defn tail [l]
  ;; TODO
  )

;; 空リストの場合に `nil` を返すこともできるが、ここでは例外をスローするようにしている。

;; Exercise 3.3: リストの先頭要素を別の値に置き換える関数 `set-head` を定義せよ。

(s/fdef set-head
  :args (s/cat :l list?
               :h any?)
  :ret list?)

(defn set-head [l h]
  ;; TODO
  )

;; Exercise 3.4: リストの先頭から `n` 個の要素を取り除く関数 `drop` を定義せよ。

(s/fdef drop
  :args (s/cat :n integer?
               :l list?)
  :ret list?)

(defn drop [n l]
  ;; TODO
  )

;; Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数 `drop-while` を定義せよ。

(s/fdef drop-while
  :args (s/cat :f ifn?
               :l list?)
  :ret list?)

(defn drop-while [f l]
  ;; TODO
  )

;; Exercise 3.6: 末尾要素以外のリストを返す関数 `init` を定義せよ。

(s/fdef init
  :args (s/cat :l list?)
  :ret list?)

(defn init [l]
  ;; TODO
  )

;; このリストの実装は単方向連結リストであり、最終要素を除外したリストを得るにはリスト全体を走査し再構築する必要がある。

;; Exercise 3.7: `fold-right` によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか?

;; Exercise 3.8: `fold-right` の引数 `acc` に `nil` 、 `f` に `#(Cons. %1 %2)` を与えるとどのような結果が得られるか? (推測してからREPLで確認してみよう)

;; Exercise 3.9: リストの要素数を数える関数 `length` を定義せよ。

(s/fdef length
  :args (s/cat :l list?)
  :ret int?)

(defn length [l]
  ;; TODO
  )

;; Exercise 3.10: リストを左端から畳み込む `fold-left` 関数を末尾再帰関数として定義せよ。

(s/fdef fold-left
  :args (s/cat :f ifn?
               :acc any?
               :as list?)
  :ret any?)

(defn fold-left [f acc as]
  ;; TODO
  )

;; Exercise 3.11: `fold-left` を用いて `sum`, `product`, `length` を定義せよ。

(s/fdef sum-via-fold-left
  :args (s/cat :ns (s/and list?
                          #(every? integer? %)))
  :ret integer?)

(defn sum-via-fold-left [ns]
  ;; TODO
  )

(s/fdef product-via-fold-left
  :args (s/cat :ns (s/and list?
                          #(every? integer? %)))
  :ret integer?)

(defn product-via-fold-left [ns]
  ;; TODO
  )

(s/fdef length-via-fold-left
  :args (s/cat :l list?)
  :ret int?)

(defn length-via-fold-left [l]
  ;; TODO
  )

;; Exercise 3.12: `fold-left` を用いてリストを逆順にする関数 `reverse` を定義せよ。

(s/fdef reverse
  :args (s/cat :l list?)
  :ret list?)

(defn reverse [l]
  ;; TODO
  )

;; Exercise 3.13: `fold-left` を用いて `fold-right` を定義することは可能か? 可能であれば定義せよ。

;; Exercise 3.14: `fold-right` を用いて `append` を定義せよ。

(s/fdef append-via-fold-right
  :args (s/cat :a1 list?
               :a2 list?)
  :ret list?)

(defn append-via-fold-right [a1 a2]
  ;; TODO
  )

;; Exercise 3.15: `fold-right` を用いてリストのリストを1つのリストに連結する関数 `concat` を定義せよ。

(s/fdef concat
  :args (s/cat :ls (s/and list?
                          #(every? (some-fn nil? cons?) %)))
  :ret list?)

(defn concat [ls]
  ;; TODO
  )

;; Exercise 3.16: `fold-right` を用いてリストの各要素に1を加える関数 `increment-each` を定義せよ。

(s/fdef increment-each
  :args (s/cat :ns (s/and list?
                          #(every? integer? %)))
  :ret (s/and list?
              #(every? integer? %)))

(defn increment-each [ns]
  ;; TODO
  )

;; Exercise 3.17: `fold-right` を用いてリストの各要素の数値を文字列に変換する関数 `double->string` を定義せよ。

(s/fdef double->string
  :args (s/cat :ns (s/and list?
                          #(every? double? %)))
  :ret (s/and list?
              #(every? string? %)))

(defn double->string [ns]
  ;; TODO
  )

;; Exercise 3.18: `double->string` を一般化して、リストの各要素に関数 `f` を適用する関数 `map` を定義せよ。

(s/fdef map
  :args (s/cat :f ifn?
               :l list?)
  :ret list?)

(defn map [f l]
  ;; TODO
  )

;; Exercise 3.19: リストの各要素を述語関数 `f` に従ってフィルタリングする関数 `filter` を定義せよ。

(s/fdef filter
  :args (s/cat :f ifn?
               :l list?)
  :ret list?)

(defn filter [f l]
  ;; TODO
  )

;; Exercise 3.20: リストの各要素を関数 `f` に適用して得られるリストのリストを1つのリストに連結する関数 `flat-map` を定義せよ。

(s/fdef flat-map
  :args (s/cat :f ifn?
               :l list?)
  :ret list?)

(defn flat-map [f l]
  ;; TODO
  )

;; Exercise 3.21: `flat-map` を用いて `filter` を定義せよ。

(s/fdef filter-via-flat-map
  :args (s/cat :f ifn?
               :l list?)
  :ret list?)

(defn filter-via-flat-map [f l]
  ;; TODO
  )

;; Exercise 3.22: リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを返す関数 `add-pairwise` を定義せよ。 `a`, `b` の長さが異なる場合、返すリストの長さは短いほうに一致する。

(s/fdef add-pairwise
  :args (s/cat :a1 (s/and list?
                          #(every? integer? %))
               :a2 (s/and list?
                          #(every? integer? %)))
  :ret (s/and list?
              #(every? integer? %)))

(defn add-pairwise [a1 a2]
  ;; TODO
  )

;; Exercise 3.23: `add-pairwise` を一般化して、リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素に関数 `f` を適用して得られたリストを返す関数 `zip-with` を定義せよ。

(s/fdef zip-with
  :args (s/cat :f ifn?
               :as list?
               :bs list?)
  :ret list?)

(defn zip-with [f as bs]
  ;; TODO
  )

;; Exercise 3.24: リスト `sup` の中にリスト `sub` が部分列として含まれているかどうかを判定する関数 `has-subsequence?` を定義せよ。
;; 例えば、 `(list 1 2 3 4)` は `(list 1 2)`, `(list 2 3)`, `(list 4)` を部分列として含むが、 `(list 1 4)` は部分列として含まない。

(s/fdef has-subsequence?
  :args (s/cat :sup list?
               :sub list?)
  :ret boolean?)

(defn has-subsequence? [sup sub]
  ;; TODO
  )

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (sum (list 1 2 4))
  (sum (list 2))
  (sum nil)

  (product (list 1 2 4))
  (product (list 2))
  (product nil)

  (append (list 1 2) (list 3 4 5))
  (append nil (list 3 4 5))
  (append (list 1 2) nil)

  (sum-via-fold-right (list 1 2 4))
  (sum-via-fold-right (list 2))
  (sum-via-fold-right nil)

  (product-via-fold-right (list 1 2 4))
  (product-via-fold-right (list 2))
  (product-via-fold-right nil)

  (tail (list 1 2 3))
  (tail (list 2))
  (tail nil)

  (set-head (list 1 2 3) 4)
  (set-head (list 2) 4)
  (set-head nil 4)

  (drop 1 (list 1 2 3))
  (drop 3 (list 1 2 3))
  (drop 4 (list 1 2 3))

  (drop-while #(< % 2) (list 1 2 3))
  (drop-while #(< % 3) (list 1 2 3))
  (drop-while #(< % 4) (list 1 2 3))

  (init (list 1 2 3))
  (init (list 2))
  (init nil)

  (length (list :a :b :c))
  (length (list :a))
  (length nil)

  (sum-via-fold-left (list 1 2 4))
  (sum-via-fold-left (list 2))
  (sum-via-fold-left nil)
  (product-via-fold-left (list 1 2 4))
  (product-via-fold-left (list 2))
  (product-via-fold-left nil)
  (length-via-fold-left (list :a :b :c))
  (length-via-fold-left (list :a))
  (length-via-fold-left nil)

  (reverse (list 1 2 3))

  (append-via-fold-right (list 1 2) (list 3 4 5))
  (append-via-fold-right nil (list 3 4 5))
  (append-via-fold-right (list 1 2) nil)

  (concat (list (list 1 2) (list 3 4 5) (list 6)))
  (concat (list (list 3 4 5)))

  (increment-each (list 1 2 3))

  (double->string (list 1.2 2.3 3.4))

  (map #(* % %) (list 1 2 3))

  (filter odd? (list 1 2 3))

  (flat-map #(list % %) (list 1 2 3))

  (filter-via-flat-map odd? (list 1 2 3))

  (add-pairwise (list 1 2 3) (list 4 5))
  (add-pairwise (list 1 2) (list 3 4 5))

  (zip-with * (list 1 2 3) (list 4 5))
  (zip-with * (list 1 2) (list 3 4 5))

  (has-subsequence? (list 1 2 3 4 5) (list 1 2 3))
  (has-subsequence? (list 1 2 3 4 5) (list 3 4))
  (has-subsequence? (list 1 2 3 4 5) (list 5))
  (has-subsequence? (list 1 2 3 4 5) (list 1 3))
  )
