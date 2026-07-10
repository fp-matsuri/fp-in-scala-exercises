(ns fp-in-clojure.exercises.getting-started.polymorphic-functions
  (:refer-clojure :exclude [sorted?])
  (:require
   [clojure.spec.alpha :as s]))

;; こちらは多相(ポリモーフィック)版の `find-first` であり、
;; `any?` なものが探している要素かどうかをテストする関数でパラメータ化されている。
;; `string?` をハードコードする代わりに `any?` 型をパラメータとしてとる。
;; そして、与えられたキーに対する等価判定をハードコードする代わりに
;; シーケンスの個々の要素をテストする関数をとる。
;; NOTE: clojure.specにはパラメータ多相/ジェネリクスに相当する仕組みがないため、specでは単純な `any?`, `ifn?` で代用している。
;; Scala風の型表記: `find-first: (p: A => Boolean, as: Sequence[A]) => Int`

(s/fdef find-first
  :args (s/cat :p ifn?
               :as (s/coll-of any?))
  :ret int?)

(defn find-first [p as]
  (loop [n 0]
    (cond
      (>= n (count as)) -1
      ;; 関数 `p` が現在の要素にマッチしたら、
      ;; 合うものが見つかったということでシーケンスのそのインデックスを返す。
      (p (nth as n)) n
      :else (recur (inc n)))))

;; Exercise 2.2: シーケンスがソート済みかどうかを判定する多相関数を定義せよ。
;; 第1引数 `gt` はシーケンス `as` の隣接する2要素をとって最初の要素が2番目の要素より大きいかどうかを判定する述語関数。
;; Scala風の型表記: `sorted?: (gt: (A, A) => Boolean, as: Sequence[A]) => Boolean`

(s/fdef sorted?
  :args (s/cat :gt ifn?
               :as (s/coll-of any?))
  :ret boolean?)

(defn sorted? [gt as]
  ;; TODO
  )

;; 多相関数はたいてい型によって制約されているため、対応する実装がひとつしかないことがある。
;; 第2引数 `f` は引数を2つとる関数、戻り値は引数を1つとる関数。
;; Scala風の型表記: `partial1: (a: A, f: (A, B) => C) => (B => C)`

(s/fdef partial1
  :args (s/cat :a any?
               :f ifn?)
  :ret ifn?)

(defn partial1 [a f]
  (fn [b] (f a b)))

;; Exercise 2.3: `curry` を実装せよ。
;; 引数 `f` は引数を2つとる関数。
;; Scala風の型表記: `curry: (f: (A, B) => C) => (A => B => C)`

(s/fdef curry
  :args (s/cat :f ifn?)
  :ret ifn?)

(defn curry [f]
  ;; TODO
  )

;; Exercise 2.4: `uncurry` を実装せよ。
;; 引数 `f` は引数を1つとってさらに引数を1つとる関数を返す関数、戻り値は引数を2つとる関数。
;; Scala風の型表記: `uncurry: (f: A => B => C) => ((A, B) => C)`

(s/fdef uncurry
  :args (s/cat :f ifn?)
  :ret ifn?)

(defn uncurry [f]
  ;; TODO
  )

;; これら2つの形式を行き来できることに注目しよう。curryしてuncurryすることができ、これら2つの形式はある意味で「同じ」だといえる。
;; FPの専門用語では、これらは _同型(isomorphic)_ ("iso" = same; "morphe" = shape, form)であると言い、圏論(category theory)から引き継がれた用語だ。

;; Exercise 2.5: `compose` を実装せよ。
;; 引数 `f`, `g` 、戻り値はいずれも引数を1つとる関数。
;; Scala風の型表記: `compose: (f: B => C, g: A => B) => (A => C)`

(s/fdef compose
  :args (s/cat :f ifn?
               :g ifn?)
  :ret ifn?)

(defn compose [f g]
  ;; TODO
  )

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (find-first #(== % 2) [2 5 1 4 3])

  (find-first #(== % 4) [2 5 1 4 3])

  (find-first #(== % 3) [2 5 1 4 3])

  (find-first #(== % 0) [2 5 1 4 3])

  (find-first #(== % 2) [])

  (sorted? > [2 5 1 4 3])

  (sorted? > [1 2 3 4 5])

  (sorted? > [1 1 3 4 5])

  ((partial1 1 #(+ %1 %2)) 2)

  (((curry #(+ %1 %2)) 1) 2)

  ((uncurry (fn [a] (fn [b] (+ a b)))) 1 2)

  ((compose #(* % 2) #(* % % %)) 3)

  ((compose #(* % % %) #(* % 2)) 3)
  )
