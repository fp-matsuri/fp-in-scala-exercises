(ns fp-in-clojure.exercises.data-structures.tree-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as sgen]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.generators :as gen]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.data-structures.tree :as sut]
   [fp-in-clojure.exercises.data-structures.tree :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(defn- gen-tree [g]
  (gen/let [leaf? (sgen/frequency [[4 (sgen/return true)]
                                   [1 (sgen/return false)]])]
    (if leaf?
      (sgen/fmap #(sut/->Leaf %) g)
      (gen/let [left (gen-tree g)
                right (gen-tree g)]
        (sut/->Branch left right)))))

(def ^:private gen-int-tree
  (gen-tree (s/gen int?)))

(defn- tree->seq [t]
  (if (sut/leaf? t)
    [(:value t)]
    (as-> [nil] v
          (apply conj v (tree->seq (:left t)))
          (apply conj v (tree->seq (:right t))))))

(tc/defspec size-test 1000
  (prop/for-all [t gen-int-tree]
    (= (count (tree->seq t))
       (sut/size t))))

(tc/defspec first-positive-test 1000
  (prop/for-all [t gen-int-tree]
    (= (let [xs (tree->seq t)]
         (or (some (fn [x] (when (and x (pos? x)) x)) xs)
             (last xs)))
       (sut/first-positive t))))

(tc/defspec maximum-test 1000
  (prop/for-all [t gen-int-tree]
    (= (->> (tree->seq t)
            (filter some?)
            (apply max))
       (sut/maximum t))))

(tc/defspec depth-test 1000
  (prop/for-all [t gen-int-tree]
    (if (sut/leaf? t)
      (zero? (sut/depth t))
      (= (inc (max (sut/depth (:left t))
                   (sut/depth (:right t))))
         (sut/depth t)))))

(tc/defspec map-test 1000
  (prop/for-all [t gen-int-tree]
    (= (map #(some-> % str) (tree->seq t))
       (tree->seq (sut/map str t)))))

(tc/defspec fold-test 1000
  (prop/for-all [t gen-int-tree]
    (= (apply str (tree->seq t))
       (sut/fold str str t))))

(tc/defspec depth-via-fold-test 1000
  (prop/for-all [t gen-int-tree]
    (if (sut/leaf? t)
      (zero? (sut/depth-via-fold t))
      (= (inc (max (sut/depth-via-fold (:left t))
                   (sut/depth-via-fold (:right t))))
         (sut/depth-via-fold t)))))

(tc/defspec map-via-fold-test 1000
  (prop/for-all [t gen-int-tree]
    (= (map #(some-> % str) (tree->seq t))
       (tree->seq (sut/map-via-fold str t)))))

(tc/defspec maximum-via-fold-test 1000
  (prop/for-all [t gen-int-tree]
    (= (->> (tree->seq t)
            (filter some?)
            (apply max))
       (sut/maximum-via-fold t))))
