(ns fp-in-clojure.answers.introduction.first-example
  (:require
   [clojure.spec.alpha :as s]
   [fp-in-clojure.exercises.introduction.first-example.coffee :as-alias coffee]))

(s/def ::coffee/price double?)
(s/def ::coffee/coffee (s/keys :req [::coffee/price]))

(s/fdef make-coffee
  :args (s/cat)
  :ret ::coffee/coffee)

(defn make-coffee []
  #::coffee{:price 2.0})

(s/fdef charge-credit-card
  :args (s/cat :price ::coffee/price)
  :ret any?)

(defn charge-credit-card [price]
  (println "charging" price))

(s/fdef buy-coffee
  :args (s/cat :charge ifn?)
  :ret ::coffee/coffee)

(defn buy-coffee [charge]
  (let [{::coffee/keys [price] :as coffee} (make-coffee)]
    (charge price)
    coffee))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (buy-coffee charge-credit-card)
  )
