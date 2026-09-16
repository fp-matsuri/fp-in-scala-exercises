(ns fp-in-clojure.exercises.state.rng-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as sgen]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.state.rng :as sut]
   [fp-in-clojure.exercises.state.rng :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(def ^:private gen-RNG (sgen/fmap sut/->RNG (s/gen int?)))
(def ^:private gen-counter (s/gen (s/int-in 10 100)))
(def ^:private gen-length-of-list (s/gen (s/int-in -5 20)))
(def ^:private gen-small-pos-num (s/gen (s/int-in 1 1000)))
(defn- in-interval? [d] (and (>= d 0) (< d 1)))

(defn- check-RND [correct? init counter rand]
  (loop [rng init
         counter counter
         previous nil]
    (if (pos? counter)
      (let [[v rng'] (rand rng)]
        (if (or (not (correct? v))
                (= v previous))
          false
          (recur rng' (dec counter) v)))
      true)))

(defn- check-RND-unit [constant init counter]
  (loop [rng init
         counter counter]
    (if (pos? counter)
      (let [[v rng'] ((sut/unit constant) rng)]
        (if (not= v constant)
          false
          (recur rng' (dec counter))))
      true)))

(defn- check-RND-non-negative-less-than [limit init counter rand]
  (loop [rng init
         counter counter]
    (if (pos? counter)
      (let [[i rng'] (rand rng)]
        (if (or (neg? i)
                (>= i limit))
          false
          (recur rng' (dec counter))))
      true)))

(tc/defspec next-int-test 1000
  (prop/for-all [rng gen-RNG]
    (let [[n1 rng'] (sut/next-int rng)
          [n2 rng''] (sut/next-int rng')
          [n3 _] (sut/next-int rng'')
          [n4 _] (sut/next-int rng)
          [n5 _] (sut/next-int rng')]
      (and (not= n1 n2)
           (not= n1 n3)
           (= n1 n4)
           (not= n2 n3)
           (= n2 n5)))))

(tc/defspec int-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (constantly true) rng counter (sut/int))))

(tc/defspec unit-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (and (check-RND-unit "unit" rng counter)
         (check-RND-unit 0 rng counter)
         (check-RND-unit 0.0 rng counter))))

(tc/defspec map-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (comp some? parse-long) rng counter (sut/map str (sut/int)))))

(tc/defspec non-negative-int-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (complement neg?) rng counter (sut/non-negative-int))))

(tc/defspec double-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND in-interval? rng counter (sut/double))))

(tc/defspec int-double-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (fn [[_ d]] (in-interval? d)) rng counter (sut/int-double))))

(tc/defspec double-int-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (fn [[d _]] (in-interval? d)) rng counter (sut/double-int))))

(tc/defspec double3-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (fn [[d1 d2 d3]]
                 (and (in-interval? d1)
                      (in-interval? d2)
                      (in-interval? d3)
                      (not= d1 d2)
                      (not= d2 d3)
                      (not= d3 d1)))
               rng counter (sut/double3))))

(tc/defspec ints-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter
                 length gen-length-of-list]
    (if (pos? length)
      (check-RND #(= % (distinct %)) rng counter (sut/ints length))
      (->> ((sut/ints length) rng) first empty?))))

(tc/defspec -double-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND in-interval? rng counter (sut/-double))))

(tc/defspec map2-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (fn [[d1 d2]]
                 (and (in-interval? d1)
                      (in-interval? d2)
                      (not= d1 d2)))
               rng counter (sut/map2 vector (sut/double) (sut/double)))))

(tc/defspec sequence-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter
                 length gen-length-of-list]
    (let [ints (sut/sequence (repeat length (sut/int)))]
      (if (pos? length)
        (check-RND #(= % (distinct %))
                   rng counter ints)
        (->> (ints rng) first empty?)))))

(tc/defspec flat-map-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter
                 limit gen-small-pos-num]
    (check-RND-non-negative-less-than limit rng counter (sut/non-negative-less-than limit))))

(tc/defspec map-via-flat-map-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (comp some? parse-long) rng counter (sut/map-via-flat-map str (sut/int)))))

(tc/defspec map2-via-flat-map-test 1000
  (prop/for-all [rng gen-RNG
                 counter gen-counter]
    (check-RND (fn [[d1 d2]]
                 (and (in-interval? d1)
                      (in-interval? d2)
                      (not= d1 d2)))
               rng counter (sut/map2-via-flat-map vector (sut/double) (sut/double)))))
