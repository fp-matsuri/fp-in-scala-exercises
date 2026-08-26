(ns fp-in-clojure.exercises.state.rng
  (:refer-clojure :exclude [boolean double int ints map sequence])
  (:require
   [clojure.core :as core]
   [clojure.spec.alpha :as s]))

(defrecord RNG [seed])

(s/fdef rng?
  :args (s/cat :x any?)
  :ret boolean?)

(defn rng? [x]
  (instance? RNG x))

;; Scala風の型表記: `next-int: (rng: RNG) => (Integer, RNG)`
(s/fdef next-int
  :args (s/cat :rng rng?)
  :ret (s/tuple integer? rng?))

(defn next-int [rng]
  (let [{:keys [seed]} rng
        ;; 現在のシード値から新たなシード値を生成する(線形合同法による)
        new-seed (bit-and (+ (unchecked-multiply seed 0x5deece66d) 0xb) 0xffffffffffff)
        next-rng (->RNG new-seed)
        n (.intValue ^Number (bit-shift-right new-seed 16))]
    ;; 戻り値は擬似乱数の整数と次のシード値のタプル
    [n next-rng]))

;; Scala風の型表記: `Rand[A]: RNG => (A, RNG)`
(s/def ::rand fn?)

;; Scala風の型表記: `int: Unit => Rand[Integer]`
(s/fdef int
  :args (s/cat)
  :ret ::rand)

(defn int []
  (fn [rng] (next-int rng)))

;; Scala風の型表記: `unit: (a: A) => Rand[A]`
(s/fdef unit
  :args (s/cat :a any?)
  :ret ::rand)

(defn unit [a]
  (fn [rng] [a rng]))

;; Scala風の型表記: `map: (f: A => B, ra: Rand[A]) => Rand[B]`
(s/fdef map
  :args (s/cat :f ifn?
               :ra ::rand)
  :ret ::rand)

(defn map [f ra]
  (fn [rng]
    (let [[a rng'] (ra rng)]
      [(f a) rng'])))

;; Exercise 6.1: 非負整数をランダム生成する関数 `non-negative-int` を実装せよ。

(s/fdef non-negative-int
  :args (s/cat)
  :ret ::rand)

(defn non-negative-int []
  ;; TODO
  )

;; Exercise 6.2: 0以上1未満の浮動小数点数をランダム生成する関数 `double` を実装せよ。

(s/fdef double
  :args (s/cat)
  :ret ::rand)

(defn double []
  ;; TODO
  )

(s/fdef boolean
  :args (s/cat)
  :ret ::rand)

(defn boolean []
  (fn [rng]
    (let [[i rng'] ((int) rng)]
      [(even? i) rng'])))

;; Exercise 6.3: 整数と浮動小数点数の組をランダム生成する関数 `int-double` と `double-int` を実装せよ。
;; また、浮動小数点数の3つ組をランダム生成する関数 `double3` を実装せよ。

(s/fdef int-double
  :args (s/cat)
  :ret ::rand)

(defn int-double []
  ;; TODO
  )

(s/fdef double-int
  :args (s/cat)
  :ret ::rand)

(defn double-int []
  ;; TODO
  )

(s/fdef double3
  :args (s/cat)
  :ret ::rand)

(defn double3 []
  ;; TODO
  )

;; Exercise 6.4: 引数で指定された要素数の整数リストをランダム生成する関数 `ints` を実装せよ。

(s/fdef ints
  :args (s/cat :c integer?)
  :ret ::rand)

(defn ints [c]
  ;; TODO
  )

;; Exercise 6.5: `map` を用いて `double` を実装せよ。

(s/fdef -double
  :args (s/cat)
  :ret ::rand)

(defn -double []
  ;; TODO
  )

;; Exercise 6.6: 関数 `map2` を実装せよ。

(s/fdef map2
  :args (s/cat :f ifn?
               :ra ::rand
               :rb ::rand)
  :ret ::rand)

(defn map2 [f ra rb]
  ;; TODO
  )

(s/fdef both
  :args (s/cat :ra ::rand
               :rb ::rand)
  :ret ::rand)

(defn both [ra rb]
  (map2 vector ra rb))

(s/fdef rand-int-double
  :args (s/cat)
  :ret ::rand)

(defn rand-int-double []
  (both (int) (double)))

(s/fdef rand-double-int
  :args (s/cat)
  :ret ::rand)

(defn rand-double-int []
  (both (double) (int)))

;; Exercise 6.7: 関数 `sequence` を実装せよ。

(s/fdef sequence
  :args (s/cat :rs (s/coll-of ::rand))
  :ret ::rand)

(defn sequence [rs]
  ;; TODO
  )

(s/fdef -ints
  :args (s/cat :c integer?)
  :ret ::rand)

(defn -ints [c]
  (sequence (repeat c (int))))

;; Exercise 6.8: 関数 `flat-map` を実装せよ。

(s/fdef flat-map
  :args (s/cat :f ifn?
               :ra ::rand)
  :ret ::rand)

(defn flat-map [f ra]
  ;; TODO
  )

(s/fdef non-negative-less-than
  :args (s/cat :n integer?)
  :ret ::rand)

(defn non-negative-less-than [n]
  (flat-map (fn [i]
              (let [modulo (mod i n)]
                (if (neg? (- (+ i (dec n)) modulo))
                  (non-negative-less-than n)
                  (unit modulo))))
            (non-negative-int)))

;; Exercise 6.9: `flat-map` を用いて `map`, `map2` を実装せよ。

(s/fdef map-via-flat-map
  :args (s/cat :f ifn?
               :ra ::rand)
  :ret ::rand)

(defn map-via-flat-map [f ra]
  ;; TODO
  )

(s/fdef map2-via-flat-map
  :args (s/cat :f ifn?
               :ra ::rand
               :rb ::rand)
  :ret ::rand)

(defn map2-via-flat-map [f ra rb]
  ;; TODO
  )

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (next-int (->RNG 42))
  (next-int (->RNG -42))

  ((int) (->RNG 42))
  ((int) (->RNG -42))

  ((unit 42) (->RNG 42))

  ((map str (int)) (->RNG 42))

  ((non-negative-int) (->RNG 42))
  ((non-negative-int) (->RNG -42))

  ((double) (->RNG 42))

  ((boolean) (->RNG 42))
  ((boolean) (->RNG 21))

  ((int-double) (->RNG 42))

  ((double-int) (->RNG 42))

  ((double3) (->RNG 42))

  ((ints 5) (->RNG 42))

  ((-double) (->RNG 42))

  ((map2 vector (int) (double)) (->RNG 42))
  ((map2 + (int) (double)) (->RNG 42))

  ((rand-int-double) (->RNG 42))

  ((rand-double-int) (->RNG 42))

  ((sequence [(int) (int) (int)]) (->RNG 42))
  ((sequence []) (->RNG 42))

  ((-ints 5) (->RNG 42))

  ((flat-map (fn [x] (unit [x x])) (int)) (->RNG 42))

  ((non-negative-less-than 100) (->RNG 42))

  ((map-via-flat-map str (int)) (->RNG 42))

  ((map2-via-flat-map vector (int) (double)) (->RNG 42))
  )
