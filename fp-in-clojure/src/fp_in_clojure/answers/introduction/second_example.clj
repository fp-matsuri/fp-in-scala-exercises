(ns fp-in-clojure.answers.introduction.second-example
  (:require
   [clojure.spec.alpha :as s]
   [fp-in-clojure.exercises.introduction.first-example.coffee :as-alias coffee]
   [fp-in-clojure.exercises.introduction.first-example.credit-card :as-alias credit-card]
   [fp-in-clojure.exercises.introduction.first-example.payment :as-alias payment]))

(s/def ::coffee/price double?)
(s/def ::coffee/coffee (s/keys :req [::coffee/price]))

(s/fdef make-coffee
  :args (s/cat)
  :ret ::coffee/coffee)

(defn make-coffee []
  #::coffee{:price 2.0})

(s/def ::credit-card/id string?)
(s/def ::credit-card/credit-card (s/keys :req [::credit-card/id]))

(s/def ::payment/type keyword?)
(s/def ::payment/credit-card ::credit-card/credit-card)
(s/def ::payment/amount double?)

(s/def ::payment/payment
  (s/keys :req [::payment/type
                ::payment/credit-card
                ::payment/amount]))

(s/fdef charge
  :args (s/cat :payment ::payment/payment)
  :ret any?)

(defmulti charge ::payment/type)

(defmethod charge :simulated-credit-card [{::payment/keys [credit-card amount]}]
  (println "charging" amount "to" credit-card))

(s/fdef buy-coffee
  :args (s/cat :credit-card ::credit-card/credit-card
               :payment-type ::payment/type)
  :ret ::coffee/coffee)

(defn buy-coffee [credit-card payment-type]
  (let [{::coffee/keys [price] :as coffee} (make-coffee)]
    (charge #::payment{:type payment-type
                       :credit-card credit-card
                       :amount price})
    coffee))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (buy-coffee #::credit-card{:id "A"}
              :simulated-credit-card)
  )
