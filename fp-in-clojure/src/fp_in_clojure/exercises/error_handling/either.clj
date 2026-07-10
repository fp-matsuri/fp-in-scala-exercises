(ns fp-in-clojure.exercises.error-handling.either
  (:refer-clojure :exclude [map sequence])
  (:require
   [clojure.spec.alpha :as s]))

(defrecord Left [error])
(defrecord Right [value])

(s/fdef left?
  :args (s/cat :x any?)
  :ret boolean?)

(defn left? [x]
  (instance? Left x))

(s/fdef right?
  :args (s/cat :x any?)
  :ret boolean?)

(defn right? [x]
  (instance? Right x))

(s/fdef either?
  :args (s/cat :x any?)
  :ret boolean?)

(defn either? [x]
  (or (left? x)
      (right? x)))

;; Exercise 4.6: Optionに準じて `map`, `flat-map`, `or-else`, `map2` を実装せよ。

(s/fdef map
  :args (s/cat :f ifn?
               :e either?)
  :ret either?)

(defn map [f e]
  ;; TODO
  )

(s/fdef flat-map
  :args (s/cat :f ifn?
               :e either?)
  :ret either?)

(defn flat-map [f e]
  ;; TODO
  )

(s/fdef or-else
  :args (s/cat :other either?
               :e either?)
  :ret either?)

(defn or-else [other e]
  ;; TODO
  )

(s/fdef map2
  :args (s/cat :f ifn?
               :a either?
               :b either?)
  :ret either?)

(defn map2 [f a b]
  ;; TODO
  )

;; Exercise 4.7: Optionに準じて `traverse`, `sequence` を実装せよ。
;; Scala風の型表記: `traverse: (A => Either[E, B], Seq[A]) => Either[E, Seq[B]]`
;; Scala風の型表記: `sequence: Seq[Either[E, A]] => Either[E, Seq[A]]`

(s/fdef traverse
  :args (s/cat :f ifn?
               :xs coll?)
  :ret either?)

(defn traverse [f xs]
  ;; TODO
  )

(s/fdef sequence
  :args (s/cat :xs (s/coll-of either?))
  :ret either?)

(defn sequence [xs]
  ;; TODO
  )

(s/fdef mean
  :args (s/cat :xs (s/coll-of number?))
  :ret either?)

(defn mean [xs]
  (if (empty? xs)
    (->Left "mean of empty list!")
    (->Right (/ (apply + xs)
                (count xs)))))

(s/fdef safe-div
  :args (s/cat :x number?
               :y number?)
  :ret either?)

(defn safe-div [x y]
  (try
    (->Right (/ x y))
    (catch Exception ex (->Left ex))))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (map inc (->Right 42))
  (map inc (->Left "falsity"))



  (flat-map (fn [x]
              (if (even? x)
                (->Right x)
                (->Left "odd")))
            (->Right 2))

  (flat-map (fn [x]
              (if (even? x)
                (->Right x)
                (->Left "odd")))
            (->Right 3))

  (flat-map  (fn [x]
               (if (even? x)
                 (->Right x)
                 (->Left "odd")))
             (->Left "n/a"))



  (or-else (->Right \b) (->Right \a))
  (or-else (->Left \β) (->Right \a))
  (or-else (->Right \b) (->Left \α))
  (or-else (->Left \β) (->Left \α))

  (map2 + (->Right 1) (->Right 2))
  (map2 + (->Left "foo") (->Right 2))
  (map2 + (->Right 1) (->Left "bar"))
  (map2 + (->Left "foo") (->Left "bar"))



  (traverse (fn [x] (if (odd? x) (->Right x) (->Left "even")))
            [])

  (traverse (fn [x] (if (odd? x) (->Right x) (->Left "even")))
            [1 3 5])

  (traverse (fn [x] (if (odd? x) (->Right x) (->Left "even")))
            [1 4 5])



  (sequence [])
  (sequence [(->Right 1) (->Right 2)])
  (sequence [(->Left "foo") (->Right 2)])
  (sequence [(->Right 1) (->Left "bar")])
  (sequence [(->Left "foo") (->Left "bar")])

  (mean [])
  (mean [1.5 0.5 2.5])

  (safe-div 3 2)
  (safe-div 3 0)
  )
