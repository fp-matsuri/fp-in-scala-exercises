(ns fp-in-clojure.exercises.getting-started.polymorphic-functions-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as sgen]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.generators :as gen]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.getting-started.polymorphic-functions :as sut]
   [fp-in-clojure.exercises.common :as common]
   [fp-in-clojure.exercises.getting-started.polymorphic-functions :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns*))

(def ^:private mul-curry
  (sut/curry *'))

(def ^:private mul-uncurry
  (sut/uncurry (fn [a] (fn [b] (*' a b)))))

(def ^:private gen-sorted-seq
  (sgen/fmap sort (s/gen (s/coll-of int?))))

(def ^:private gen-unsorted-seq
  (gen/let [n (s/gen (s/int-in 2 20))
            coll (s/gen (s/coll-of ::common/short-number :count n))]
    (map-indexed (fn [i num]
                   (if (even? i)
                     (+ num 100)
                     (- num 100)))
                 coll)))

(tc/defspec sorted?-for-sorted-seq-test 1000
  (prop/for-all [coll gen-sorted-seq]
    (true? (sut/sorted? coll >))))

(tc/defspec sorted?-for-unsorted-seq-test 1000
  (prop/for-all [coll gen-unsorted-seq]
    (false? (sut/sorted? coll >))))

(tc/defspec curry-test 1000
  (prop/for-all [n (s/gen int?)
                 m (s/gen int?)]
    (= (*' n m)
       ((mul-curry n) m))))

(tc/defspec uncurry-test 1000
  (prop/for-all [n (s/gen int?)
                 m (s/gen int?)]
    (= (*' n m)
       (mul-uncurry n m))))

(tc/defspec compose-test 1000
  (prop/for-all [n (s/gen int?)
                 m (s/gen int?)]
    (let [a->c (sut/compose (fn [b] (*' n b))
                            (fn [a] (*' m a)))]
      (= (*' n m)
         (a->c 1)))))
