(ns fp-in-clojure.test-helper
  (:require
   [clojure.spec.test.alpha :as stest]))

(defn- ns-alias->sym [ns alias]
  (some-> ns
          ns-aliases
          (get alias)
          ns-name
          symbol))

(defn- instrumentable [ns-sym]
  (filter #(= (namespace %) (name ns-sym))
          (stest/instrumentable-syms)))

(defn- instrument-ns [ns-sym]
  (stest/instrument (instrumentable ns-sym)))

(defn- unstrument-ns [ns-sym]
  (stest/unstrument (instrumentable ns-sym)))

;; fixtures

(defn instrument-specs [current-ns target-alias]
  (fn [f]
    (if-let [target-ns-sym (ns-alias->sym current-ns target-alias)]
      (do (instrument-ns target-ns-sym)
          (try
            (f)
            (finally
              (unstrument-ns target-ns-sym))))
      (f))))
