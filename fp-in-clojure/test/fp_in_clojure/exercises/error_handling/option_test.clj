(ns fp-in-clojure.exercises.error-handling.option-test
  (:require
   [clojure.math :as math]
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as sgen]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.error-handling.option :as sut]
   [fp-in-clojure.exercises.error-handling.option :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(def ^:private gen-int-option
  (sgen/one-of [(sgen/return nil)
                (sgen/fmap sut/->Some (s/gen int?))]))

(def ^:private gen-nil-seq
  (sgen/return [nil]))

(def ^:private gen-seq-with-nil
  (sgen/vector gen-int-option))

(def ^:private gen-seq-without-nil
  (sgen/vector (sgen/fmap sut/->Some (s/gen int?))))

(def ^:private gen-option-seq
  (sgen/one-of [gen-nil-seq
                gen-seq-with-nil
                gen-seq-without-nil]))

(def ^:private gen-seq-with-random-string
  (sgen/vector (sgen/one-of [(sgen/return "one")
                             (sgen/fmap str (s/gen int?))])))

(def ^:private gen-seq-with-valid-numbers
  (sgen/vector (sgen/fmap str (s/gen int?))))

(def ^:private gen-string-seq
  (sgen/one-of [gen-seq-with-random-string
                gen-seq-with-valid-numbers]))

(defn- int->string [a]
  (str a))

(defn- int->opt-string [a]
  (-> a str sut/->Some))

(defn- str->opt-int [s]
  (some-> s parse-long sut/->Some))

(def ^:private other-opt
  (sut/->Some 1))

(tc/defspec map-test 1000
  (prop/for-all [opt gen-int-option]
    (let [x (sut/map int->string opt)]
      (if (nil? opt)
        (nil? x)
        (= (-> opt :value str sut/->Some)
           x)))))

(tc/defspec get-or-else-test 1000
  (prop/for-all [opt gen-int-option]
    (let [x (sut/get-or-else 1 opt)]
      (if (nil? opt)
        (= 1 x)
        (= (:value opt) x)))))

(tc/defspec flat-map-test 1000
  (prop/for-all [opt gen-int-option]
    (let [x (sut/flat-map int->opt-string opt)]
      (if (nil? opt)
        (nil? x)
        (= (-> opt :value str sut/->Some)
           x)))))

(tc/defspec or-else-test 1000
  (prop/for-all [opt gen-int-option]
    (let [x (sut/or-else other-opt opt)]
      (if (nil? opt)
        (= other-opt x)
        (= opt x)))))

(tc/defspec filter-test 1000
  (prop/for-all [opt gen-int-option]
    (if (nil? opt)
      (nil? (sut/filter #(= % 42) opt))
      (and (= (sut/->Some (:value opt))
              (sut/filter #(= % (:value opt)) opt))
           (nil? (sut/filter #(= % (-> opt :value inc)) opt))))))

(tc/defspec mean-test 1000
  (prop/for-all [coll (sgen/vector (sgen/double* {:infinite? false :NaN? false}))]
    (= (if (empty? coll)
         nil
         (sut/->Some (/ (apply + coll)
                        (count coll))))
       (sut/mean coll))))

(tc/defspec variance-test 1000
  (prop/for-all [coll (sgen/vector (sgen/double* {:infinite? false :NaN? false}))]
    (= (if (empty? coll)
         nil
         (let [m (/ (apply + coll)
                    (count coll))
               coll' (map #(math/pow (- % m), 2) coll)]
           (sut/->Some (/ (apply + coll')
                          (count coll')))))
       (sut/variance coll))))

(tc/defspec map2-test 1000
  (prop/for-all [opt1 gen-int-option
                 opt2 gen-int-option]
    (let [x (sut/map2 + opt1 opt2)]
      (if (every? some? [opt1 opt2])
        (= (sut/->Some (+ (:value opt1) (:value opt2)))
           x)
        (nil? x)))))

(tc/defspec sequence-test 1000
  (prop/for-all [opts gen-option-seq]
    (= (if (every? some? opts)
         (->> opts
              (mapcat #(->> %
                            (sut/map vector)
                            (sut/get-or-else [])))
              sut/->Some)
         nil)
       (sut/sequence opts))))

(tc/defspec traverse-test 1000
  (prop/for-all [coll gen-string-seq]
    (= (if (some #{"one"} coll)
         nil
         (->> coll
              (map parse-long)
              sut/->Some))
       (sut/traverse str->opt-int coll))))
