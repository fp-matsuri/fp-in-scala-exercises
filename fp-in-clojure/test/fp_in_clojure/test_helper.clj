(ns fp-in-clojure.test-helper
  (:require
   [clojure.spec.test.alpha :as stest]
   [clojure.string :as str]))

(defn- test-ns->sut-ns-sym [test-ns]
  (let [test-ns-name (-> test-ns ns-name str)]
    (when (str/ends-with? test-ns-name "-test")
      (-> test-ns-name
          (str/replace #"-test$" "")
          symbol))))

(defn- instrument-ns [ns-sym]
  (->> (stest/instrumentable-syms)
       (filter #(= (namespace %) (name ns-sym)))
       stest/instrument))

(defn- unstrument-ns [ns-sym]
  (->> (stest/instrumentable-syms)
       (filter #(= (namespace %) (name ns-sym)))
       stest/unstrument))

;; fixtures

(defn instrument-specs [f]
  (if-let [sut-ns-sym (test-ns->sut-ns-sym *ns*)]
    (do (instrument-ns sut-ns-sym)
        (try
          (f)
          (finally
            (unstrument-ns sut-ns-sym))))
    (f)))
