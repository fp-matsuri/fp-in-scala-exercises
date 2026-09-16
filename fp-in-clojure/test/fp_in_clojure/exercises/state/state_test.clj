(ns fp-in-clojure.exercises.state.state-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.state.state :as sut]
   [fp-in-clojure.exercises.state.state :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(def ^:private state-a
  (sut/->State
   (fn [[head & tail]]
     [head tail])))

(def ^:private state-b
  (sut/->State
   (fn [[_ & tail :as s]]
     [(if (seq s) (-> tail count inc) 0) tail])))

(defn- length [maybe-head]
  (-> maybe-head (or "") count))

(defn- print-result [maybe-head length]
  (str "The head element is '" maybe-head "', the length is " length))

(tc/defspec map-test 1000
  (prop/for-all [coll (s/gen (s/coll-of string?))]
    (let [[b s] (sut/run-state coll (sut/map length state-a))]
      (and (= (->> coll first length)
              b)
           (= (->> coll (drop 1) seq)
              s)))))

(tc/defspec map2-test 1000
  (prop/for-all [coll (s/gen (s/coll-of string?))]
    (let [[c s] (sut/run-state coll (sut/map2 print-result state-a state-b))]
      (and (= (print-result (first coll) (->> coll (drop 1) length))
              c)
           (= (->> coll (drop 2) seq)
              s)))))

(tc/defspec flat-map-test 1000
  (prop/for-all [coll (s/gen (s/coll-of string?))]
    (let [[b s] (sut/run-state coll (sut/flat-map (comp sut/unit length) state-a))]
      (and (= (->> coll first length)
              b)
           (= (->> coll (drop 1) seq)
              s)))))

(tc/defspec unit-test 1000
  (prop/for-all [str' (s/gen string?)]
    (let [[a s] (sut/run-state 0 (sut/unit str'))]
      (and (= str' a)
           (= 0 s)))))

(tc/defspec sequence-test 1000
  (prop/for-all [coll (s/gen (s/coll-of string?))]
    (let [half (-> (count coll) (/ 2) long)
          list-of-states (repeat half state-a)
          [first-half-elements rest-elements] (sut/run-state coll (sut/sequence list-of-states))
          [first' rest'] (split-at half coll)]
      (and (= first' first-half-elements)
           (= rest' rest-elements)))))
