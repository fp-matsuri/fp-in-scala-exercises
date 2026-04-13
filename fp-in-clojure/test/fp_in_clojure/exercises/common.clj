(ns fp-in-clojure.exercises.common
  (:require
   [clojure.spec.alpha :as s]))

(def the-first-21-fibonacci-numbers
  [0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765])

(s/def ::length-of-fibonacci-seq
  (s/int-in 0 (count the-first-21-fibonacci-numbers)))

(s/def ::short-number
  (s/int-in 0 20))
