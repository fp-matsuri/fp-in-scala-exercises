(ns fp-in-clojure.exercises.data-structures.list-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as sgen]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.generators :as gen]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.data-structures.list :as sut]
   [fp-in-clojure.exercises.common :as common]
   [fp-in-clojure.exercises.data-structures.list :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(defn- clojure-seq->list [coll]
  (apply sut/list coll))

(def ^:private gen-int-list
  (->> (s/coll-of int?)
       s/gen
       (sgen/fmap clojure-seq->list)))

(def ^:private gen-double-list
  (->> (s/coll-of double?)
       s/gen
       (sgen/fmap clojure-seq->list)))

(def ^:private gen-list-of-lists
  (gen/let [length (s/gen ::common/short-number)
            ls (sgen/vector gen-int-list length)]
    (clojure-seq->list ls)))

(def ^:private gen-small-num
  (s/gen (s/int-in -10 10)))

(tc/defspec tail-test 1000
  (prop/for-all [l gen-int-list]
    (if (empty? l)
      (try
        (sut/tail l)
        false
        (catch Exception _
          true))
      (= (rest l)
         (sut/tail l)))))

(tc/defspec set-head-test 1000
  (prop/for-all [l gen-int-list]
    (if (empty? l)
      (try
        (sut/set-head l 0)
        false
        (catch Exception _
          true))
      (= (cons 0 (rest l))
         (sut/set-head l 0)))))

(tc/defspec drop-test 1000
  (prop/for-all [l gen-int-list
                 n gen-small-num]
    (= (clojure-seq->list (drop n l))
       (sut/drop n l))))

(tc/defspec drop-while-test 1000
  (prop/for-all [l gen-int-list
                 n gen-small-num]
    (let [f #(<= % n)]
      (= (clojure-seq->list (drop-while f l)) (sut/drop-while f l)))))

(tc/defspec init-test 1000
  (prop/for-all [l gen-int-list]
    (if (empty? l)
      (try
        (sut/init l)
        false
        (catch Exception _
          true))
      (= (butlast l)
         (sut/init l)))))

(tc/defspec length-test 1000
  (prop/for-all [l gen-int-list]
    (= (count l)
       (sut/length l))))

(tc/defspec fold-left-test 1000
  (prop/for-all [l gen-int-list]
    (= (reduce str "" l)
       (sut/fold-left str "" l))))

(tc/defspec sum-via-fold-left-test 1000
  (prop/for-all [l gen-int-list]
    (= (reduce +' 0 l)
       (sut/sum-via-fold-left l))))

(tc/defspec product-via-fold-left-test 1000
  (prop/for-all [l gen-double-list]
    (let [expected (reduce * 1.0 l)
          actual (sut/product-via-fold-left l)]
      (or (= expected actual)
          (every? NaN? [expected actual])))))

(tc/defspec length-via-fold-left-test 1000
  (prop/for-all [l gen-int-list]
    (= (count l)
       (sut/length-via-fold-left l))))

(tc/defspec reverse-test 1000
  (prop/for-all [l gen-int-list]
    (= (clojure-seq->list (reverse l))
       (sut/reverse l))))

(tc/defspec append-via-fold-right-test 1000
  (prop/for-all [l1 gen-int-list
                 l2 gen-int-list]
    (= (clojure-seq->list (concat l1 l2))
       (sut/append-via-fold-right l1 l2))))

(tc/defspec concat-test 100
  (prop/for-all [ls gen-list-of-lists]
    (= (clojure-seq->list (apply concat ls))
       (sut/concat ls))))

(tc/defspec increment-each-test 1000
  (prop/for-all [l gen-int-list]
    (= (clojure-seq->list (map inc l))
       (sut/increment-each l))))

(tc/defspec double->string-test 1000
  (prop/for-all [l gen-double-list]
    (= (clojure-seq->list (map str l))
       (sut/double->string l))))

(tc/defspec map-test 1000
  (prop/for-all [l gen-int-list]
    (= (clojure-seq->list (map #(*' % 2) l))
       (sut/map #(*' % 2) l))))

(tc/defspec filter-test 1000
  (prop/for-all [l gen-int-list]
    (= (clojure-seq->list (filter even? l))
       (sut/filter even? l))))

(tc/defspec flat-map-test 1000
  (prop/for-all [l gen-int-list]
    (= (clojure-seq->list (mapcat #(sut/list % %) l))
       (sut/flat-map #(sut/list % %) l))))

(tc/defspec filter-via-flat-map-test 1000
  (prop/for-all [l gen-int-list]
    (= (clojure-seq->list (filter even? l))
       (sut/filter-via-flat-map even? l))))

(tc/defspec add-pairwise-test 1000
  (prop/for-all [l1 gen-int-list
                 l2 gen-int-list]
    (= (clojure-seq->list (map +' l1 l2))
       (sut/add-pairwise l1 l2))))

(tc/defspec zip-with-test 1000
  (prop/for-all [l1 gen-int-list
                 l2 gen-int-list]
    (= (clojure-seq->list (map *' l1 l2))
       (sut/zip-with *' l1 l2))))

(defmacro ^:private try-with-default [default & body]
  `(try
     ~@body
     (catch Exception _#
       ~default)))

(tc/defspec has-subsequence?-test 1000
  (prop/for-all [l gen-int-list
                 n gen-small-num]
    (and (sut/has-subsequence? l nil)
         (sut/has-subsequence? l l)
         (sut/has-subsequence? l (try-with-default nil (sut/init l)))
         (sut/has-subsequence? l (try-with-default nil (sut/tail l)))
         (sut/has-subsequence? l (sut/drop n l)))))

(defn- contains-slice? [sup sub]
  (if (empty? sub)
    true
    (some? (some #(= sub %) (partition (count sub) 1 sup)))))

(tc/defspec has-subsequence?_random-lists-test 1000
  (prop/for-all [l1 gen-int-list
                 l2 gen-int-list]
    (= (contains-slice? l1 l2)
       (sut/has-subsequence? l1 l2))))
