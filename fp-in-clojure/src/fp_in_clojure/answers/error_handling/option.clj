(ns fp-in-clojure.answers.error-handling.option
  (:refer-clojure :exclude [filter map sequence some?])
  (:require
   [clojure.math :as math]
   [clojure.spec.alpha :as s]))

(defrecord Some [value])

(s/fdef some?
  :args (s/cat :x any?)
  :ret boolean?)

(defn some? [x]
  (instance? Some x))

(s/fdef option?
  :args (s/cat :x any?)
  :ret boolean?)

(defn option? [x]
  (or (some? x)
      (nil? x)))

;; Exercise 4.1: 関数 `map` 、 `get-or-else` 、 `flat-map` 、 `or-else` 、 `filter` を実装せよ。
;; `get-or-else` は `Some` ならその中身の値を返し、 `nil` なら引数のデフォルト値を返す。
;; `or-else` は `Some` ならそのまま返し、 `nil` なら引数のOption値を返す。

(s/fdef map
  :args (s/cat :f ifn?
               :o option?)
  :ret option?)

(defn map [f o]
  (when (some? o)
    (->> o :value f ->Some)))

(s/fdef get-or-else
  :args (s/cat :default any?
               :o option?)
  :ret any?)

(defn get-or-else [default o]
  (if (some? o)
    (:value o)
    default))

(s/fdef flat-map
  :args (s/cat :f ifn?
               :o option?)
  :ret option?)

(defn flat-map [f o]
  (->> o
       (map f)
       (get-or-else nil)))

(s/fdef or-else
  :args (s/cat :other option?
               :o option?)
  :ret option?)

(defn or-else [other o]
  (->> o
       (map ->Some)
       (get-or-else other)))

(s/fdef filter
  :args (s/cat :f ifn?
               :o option?)
  :ret option?)

(defn filter [f o]
  (flat-map (fn [a]
              (when (f a)
                (->Some a)))
            o))

(s/fdef failing-fn
  :args (s/cat)
  :ret int?)

(defn failing-fn []
  (let [y (throw (ex-info "fail!" {}))]
    (try
      (let [x (+ 42 5)]
        (+ x y))
      (catch Exception _ 43))))

(s/fdef failing-fn'
  :args (s/cat)
  :ret int?)

(defn failing-fn' []
  (try
    (let [x (+ 42 5)]
      (+ x (throw (ex-info "fail!" {}))))
    (catch Exception _ 43)))

(s/fdef mean
  :args (s/cat :xs (s/coll-of number?))
  :ret option?)

(defn mean [xs]
  ;; NOTE: シーケンスの非空判定には `seq` を使う。
  ;; ref. https://clojuredocs.org/clojure.core/seq
  (when (seq xs)
    (->Some (/ (apply + xs)
               (count xs)))))

;; Exercise 4.2: 分散(平均からの偏差の2乗の平均)を計算する関数 `variance` を定義せよ。

(s/fdef variance
  :args (s/cat :xs (s/coll-of number?))
  :ret option?)

(defn variance [xs]
  (flat-map (fn [m]
              (mean (clojure.core/map
                     (fn [x] (math/pow (- x m) 2))
                     xs)))
            (mean xs)))

;; Exercise 4.3: 2つのOption値がともに `Some` なら、2つの値に関数 `f` を適用する関数 `map2` を定義せよ。
;; どちらかが `nil` なら結果も `nil` になる。
;; Scala風の型表記: `map2: ((A, B) => C, Option[A], Option[B]) => Option[C]`

(s/fdef map2
  :args (s/cat :f ifn?
               :a option?
               :b option?)
  :ret option?)

(defn map2 [f a b]
  (flat-map (fn [aa]
              (map (fn [bb]
                     (f aa bb))
                   b))
            a))

;; Exercise 4.4: OptionのリストをリストのOptionに変換する関数 `sequence` を定義せよ。
;; Scala風の型表記: `sequence: Seq[Option[A]] => Option[Seq[A]]`

(s/fdef sequence
  :args (s/cat :xs (s/coll-of option?))
  :ret option?)

(defn sequence [xs]
  (if (empty? xs)
    (->Some nil)
    (flat-map (fn [hh]
                (map #(cons hh %)
                     (->> xs rest sequence)))
              (first xs))))

;; Exercise 4.5: リストの要素に関数 `f` を適用した結果をリストのOptionに変換する関数 `traverse` を定義せよ。
;; Scala風の型表記: `traverse: (A => Option[B], Seq[A]) => Option[Seq[B]]`

(s/fdef traverse
  :args (s/cat :f ifn?
               :xs coll?)
  :ret option?)

(defn traverse [f xs]
  (if (empty? xs)
    (->Some nil)
    (map2 cons
          (->> xs first f)
          (traverse f (rest xs)))))

(s/fdef sequence-via-traverse
  :args (s/cat :xs (s/coll-of option?))
  :ret option?)

(defn sequence-via-traverse [xs]
  (traverse identity xs))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (map inc (->Some 42))
  (map inc nil)

  (get-or-else 0 (->Some 42))
  (get-or-else 0 nil)

  (flat-map #(->Some (* % 2)) (->Some 42))
  (flat-map #(->Some (* % 2)) nil)

  (or-else (->Some \b) (->Some \a))
  (or-else (->Some \b) nil)
  (or-else nil (->Some \a))
  (or-else nil nil)

  (filter odd? (->Some 3))
  (filter odd? (->Some 4))
  (filter odd? nil)

  (failing-fn)
  (failing-fn')

  (mean [])
  (mean [1.5 0.5 2.5])

  (variance [])
  (variance [1.5 0.5 2.5])

  (map2 + (->Some 1) (->Some 2))
  (map2 + nil (->Some 2))
  (map2 + (->Some 1) nil)
  (map2 + nil nil)

  (sequence [])
  (sequence [(->Some 1) (->Some 2)])
  (sequence [nil (->Some 2)])
  (sequence [(->Some 1) nil])
  (sequence [nil nil])

  (traverse (fn [x] (when (odd? x) (->Some x)))
            [])
  (traverse (fn [x] (when (odd? x) (->Some x)))
            [1 3 5])
  (traverse (fn [x] (when (odd? x) (->Some x)))
            [1 4 5])
  )
