(ns fp-in-clojure.exercises.laziness.lazy-seq-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.laziness.lazy-seq :as sut]
   [fp-in-clojure.exercises.common :as common]
   [fp-in-clojure.exercises.laziness.lazy-seq :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(def ^:private gen-small-int (s/gen (s/int-in -100 100)))
(def ^:private gen-mid-int (s/gen (s/int-in -1000 1000)))

(tc/defspec ->seq-test 1000
  (prop/for-all [coll (s/gen seqable?)]
    (= (or (seq coll) [])
       (sut/->seq coll))))

(tc/defspec take-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen sequential?)]
    (= (take n coll)
       (sut/take n coll))))

(tc/defspec drop-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen sequential?)]
    (= (drop n coll)
       (sut/drop n coll))))

(tc/defspec take-while-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (take-while #(not= % n) coll)
       (sut/take-while #(not= % n) coll))))

(tc/defspec for-all-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (not-any? #{n} coll)
       (sut/for-all? #(not= % n) coll))))

(tc/defspec take-while'-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (take-while #(not= % n) coll)
       (sut/take-while' #(not= % n) coll))))

(tc/defspec head-option-test 1000
  (prop/for-all [coll (s/gen seqable?)]
    (= (first coll)
       (sut/head-option coll))))

(tc/defspec map-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (map #(+ % n) coll)
       (sut/map #(+ % n) coll))))

(tc/defspec filter-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (filter #(not= % n) coll)
       (sut/filter #(not= % n) coll))))

(tc/defspec append-test 1000
  (prop/for-all [coll1 (s/gen sequential?)
                 coll2 (s/gen sequential?)]
    (= (concat coll1 coll2)
       (sut/append coll1 coll2))))

(tc/defspec flat-map-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (mapcat #(list (+ % n)) coll)
       (sut/flat-map #(list (+ % n)) coll))))

(tc/defspec ones-test 1000
  (prop/for-all [n gen-mid-int]
    (= (repeat n 1)
       (take n (sut/ones)))))

(tc/defspec continually-test 1000
  (prop/for-all [n gen-mid-int
                 a gen-mid-int]
    (= (repeat n a)
       (take n (sut/continually a)))))

(tc/defspec from-test 1000
  (prop/for-all [n gen-mid-int
                 a gen-mid-int]
    (= (take n (iterate inc a))
       (take n (sut/from a)))))

(tc/defspec fibs-test 1000
  (prop/for-all [n (s/gen ::common/length-of-fibonacci-seq)]
    (= (take n common/the-first-21-fibonacci-numbers)
       (take n (sut/fibs)))))

(tc/defspec unfold-test 1000
  (prop/for-all [n gen-mid-int]
    (letfn [(gen-first-numbers [m]
              (when (<= m n)
                [m (inc m)]))]
      (= (range 1 (inc n))
         (sut/unfold gen-first-numbers 1)))))

(tc/defspec fibs-via-unfold-test 1000
  (prop/for-all [n (s/gen ::common/length-of-fibonacci-seq)]
    (= (take n common/the-first-21-fibonacci-numbers)
       (take n (sut/fibs-via-unfold)))))

(tc/defspec from-via-unfold-test 1000
  (prop/for-all [n gen-mid-int
                 a gen-mid-int]
    (= (take n (iterate inc a))
       (take n (sut/from-via-unfold a)))))

(tc/defspec continually-via-unfold-test 1000
  (prop/for-all [n gen-mid-int
                 a gen-mid-int]
    (= (repeat n a)
       (take n (sut/continually-via-unfold a)))))

(tc/defspec ones-via-unfold-test 1000
  (prop/for-all [n gen-mid-int]
    (= (repeat n 1)
       (take n (sut/ones-via-unfold)))))

(tc/defspec map-via-unfold-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (map #(+ % n) coll)
       (sut/map-via-unfold #(+ % n) coll))))

(tc/defspec take-via-unfold-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen sequential?)]
    (= (take n coll)
       (sut/take-via-unfold n coll))))

(tc/defspec take-while-via-unfold-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen (s/coll-of int?))]
    (= (take-while #(not= % n) coll)
       (sut/take-while-via-unfold #(not= % n) coll))))

(tc/defspec zip-with-test 1000
  (prop/for-all [coll1 (s/gen (s/coll-of int?))
                 coll2 (s/gen (s/coll-of int?))]
    (= (map +' coll1 coll2)
       (sut/zip-with +' coll1 coll2))))

(tc/defspec zip-all-test 1000
  (prop/for-all [coll1 (s/gen (s/coll-of int?))
                 coll2 (s/gen (s/coll-of int?))]
    (= (take (max (count coll1) (count coll2))
             (map vector
                  (lazy-cat coll1 (repeat nil))
                  (lazy-cat coll2 (repeat nil))))
       (sut/zip-all coll1 coll2))))

(tc/defspec starts-with?-test 1000
  (prop/for-all [prefix (s/gen (s/coll-of int?))
                 coll (s/gen (s/coll-of int?))]
    (and (= (= (take (count prefix) coll)
               prefix)
            (sut/starts-with? prefix coll))
         (sut/starts-with? [] coll)
         (sut/starts-with? coll coll))))

(tc/defspec tails-test 1000
  (prop/for-all [coll (s/gen (s/coll-of int?))]
    (= (map #(drop % coll) (range 0 (inc (count coll))))
       (sut/tails coll))))

(tc/defspec has-subsequence?-test 1000
  (prop/for-all [n gen-small-int
                 coll (s/gen sequential?)]
    (and (sut/has-subsequence? [] coll)
         (sut/has-subsequence? coll coll)
         (sut/has-subsequence? (drop n coll) coll))))

(defn- contains-slice? [sub sup]
  (if (empty? sub)
    true
    (some? (some #(= sub %) (partition (count sub) 1 sup)))))

(tc/defspec has-subsequence?_random-seqs-test 1000
  (prop/for-all [sub (s/gen sequential?)
                 sup (s/gen sequential?)]
    (= (contains-slice? sub sup)
       (sut/has-subsequence? sub sup))))

(tc/defspec scan-right-test 1000
  (prop/for-all [coll (s/gen (s/coll-of int?))]
    (and (= (->> coll sut/tails (map #(apply +' %)))
            (sut/scan-right +' 0 coll))
         (= (->> coll sut/tails (map #(apply *' %)))
            (sut/scan-right *' 1 coll)))))
