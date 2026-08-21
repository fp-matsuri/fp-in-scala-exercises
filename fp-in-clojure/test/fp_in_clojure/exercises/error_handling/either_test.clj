(ns fp-in-clojure.exercises.error-handling.either-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as sgen]
   [clojure.string :as str]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.generators :as gen]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.error-handling.either :as sut]
   [fp-in-clojure.exercises.common :as common]
   [fp-in-clojure.exercises.error-handling.either :as sut]
   [fp-in-clojure.exercises.error-handling.either-test.person :as-alias person]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(def ^:private gen-either
  (sgen/one-of [(sgen/fmap sut/->Left (s/gen string?))
                (sgen/fmap sut/->Right (s/gen int?))]))

(tc/defspec map-test 1000
  (prop/for-all [either gen-either]
    (= (if (sut/left? either)
         either
         (-> either :value (/ 2) sut/->Right))
       (sut/map #(/ % 2) either))))

(tc/defspec flat-map-test 1000
  (prop/for-all [either gen-either]
    (let [f (fn [n]
              (if (even? n)
                (sut/->Right (/ n 2))
                (sut/->Left "An odd number")))]
      (= (cond
           (sut/left? either) either
           (and (sut/right? either)
                (odd? (:value either))) (sut/->Left "An odd number")
           :else (-> either :value (/ 2) sut/->Right))
         (sut/flat-map f either)))))

(tc/defspec or-else-test 1000
  (prop/for-all [either1 gen-either
                 either2 gen-either]
    (= (if (sut/left? either1)
         either2
         either1)
       (sut/or-else either2 either1))))

(s/def ::person/name string?)

(s/fdef make-name
  :args (s/cat :name ::person/name)
  :ret sut/either?)

(defn make-name [name]
  (if (str/blank? name)
    (sut/->Left "Name is empty.")
    (sut/->Right name)))

(s/def ::person/age int?)

(s/fdef make-age
  :args (s/cat :age ::person/age)
  :ret sut/either?)

(defn make-age [age]
  (if (neg? age)
    (sut/->Left "Age is out of range.")
    (sut/->Right age)))

(s/def ::person/person
  (s/keys :req [::person/name
                ::person/age]))

(s/fdef make-person
  :args (s/cat :name ::person/name
               :age ::person/age)
  :ret (s/or :left sut/left?
             :right (s/and sut/right?
                           #(s/valid? ::person/person (:value %)))))

(defn make-person [name age]
  (sut/map2 #(hash-map ::person/name %1 ::person/age %2)
            (make-name name)
            (make-age age)))

(def ^:private gen-name
  (s/gen string?))

(def ^:private gen-pos-age
  (s/gen (s/int-in 1 50)))

(def ^:private gen-age
  (s/gen (s/int-in -50 50)))

(tc/defspec map2-test 1000
  (prop/for-all [name gen-name
                 age gen-age]
    (= (cond
         (str/blank? name) (sut/->Left "Name is empty.")
         (neg? age) (sut/->Left "Age is out of range.")
         :else (sut/->Right #::person{:name name :age age}))
       (sut/map2 #(hash-map ::person/name %1 ::person/age %2)
                 (make-name name)
                 (make-age age)))))

(def ^:private gen-ages-seq
  (sgen/one-of [(sgen/bind (sgen/choose 0 10)
                           #(sgen/vector gen-pos-age %))
                (sgen/bind (sgen/choose 0 10)
                           #(sgen/vector gen-age %))]))

(tc/defspec traverse-test 1000
  (prop/for-all [ages gen-ages-seq]
    (= (if (some neg? ages)
         (sut/->Left "Age is out of range.")
         (sut/->Right ages))
       (sut/traverse make-age ages))))

(tc/defspec sequence-test 1000
  (prop/for-all [ages gen-ages-seq]
    (= (if (some neg? ages)
         (sut/->Left "Age is out of range.")
         (sut/->Right ages))
       (->> ages (map make-age) sut/sequence))))
