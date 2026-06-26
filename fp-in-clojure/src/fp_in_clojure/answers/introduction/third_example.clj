(ns fp-in-clojure.answers.introduction.third-example
  (:require
   [clojure.spec.alpha :as s]
   [fp-in-clojure.exercises.introduction.third-example.charge :as-alias charge]
   [fp-in-clojure.exercises.introduction.third-example.coffee :as-alias coffee]
   [fp-in-clojure.exercises.introduction.third-example.credit-card :as-alias credit-card]))

(s/def ::coffee/price double?)
(s/def ::coffee/coffee (s/keys :req [::coffee/price]))

(s/fdef make-coffee
  :args (s/cat)
  :ret ::coffee/coffee)

(defn make-coffee []
  #::coffee{:price 2.0})

(s/def ::credit-card/id string?)
(s/def ::credit-card/credit-card (s/keys :req [::credit-card/id]))

(s/def ::charge/amount double?)
(s/def ::charge/credit-card ::credit-card/credit-card)

(s/def ::charge/charge
  (s/keys :req [::charge/credit-card
                ::charge/amount]))

(s/fdef combine-charges
  :args (s/cat :charge-a ::charge/charge
               :charge-b ::charge/charge)
  :ret ::charge/charge)

(defn combine-charges [{card-a ::charge/credit-card
                        :as charge-a}
                       {card-b ::charge/credit-card
                        :as charge-b}]
  (if (= (::credit-card/id card-a)
         (::credit-card/id card-b))
    #::charge{:credit-card card-a
              :amount (+ (::charge/amount charge-a)
                         (::charge/amount charge-b))}
    (throw (ex-info "Can't combine charges for different cards"
                    {:card-a card-a :card-b card-b}))))

(s/fdef coalesce-charges
  :args (s/cat :charges (s/coll-of ::charge/charge))
  :ret (s/coll-of ::charge/charge))

(defn coalesce-charges [charges]
  (->> charges
       (group-by ::charge/credit-card)
       vals
       (map #(reduce combine-charges %))))

(s/fdef buy-coffee
  :args (s/cat :cc ::credit-card/credit-card)
  :ret (s/tuple ::coffee/coffee
                ::charge/charge))

(defn buy-coffee [cc]
  (let [{::coffee/keys [price] :as coffee} (make-coffee)
        charge #::charge{:credit-card cc
                         :amount price}]
    [coffee charge]))

(s/fdef buy-coffees
  :args (s/cat :cc ::credit-card/credit-card
               :n nat-int?)
  :ret (s/tuple (s/coll-of ::coffee/coffee)
                ::charge/charge))

(defn buy-coffees [cc n]
  (let [[coffees charges] (->> (buy-coffee cc)
                               (repeat n)
                               (apply map vector))]
    [coffees (reduce combine-charges #::charge{:credit-card cc :amount 0.0} charges)]))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (combine-charges #::charge{:credit-card #::credit-card{:id "A"}
                             :amount 1.0}
                   #::charge{:credit-card #::credit-card{:id "A"}
                             :amount 2.0})

  (combine-charges #::charge{:credit-card #::credit-card{:id "A"}
                             :amount 1.0}
                   #::charge{:credit-card #::credit-card{:id "B"}
                             :amount 2.0})

  (coalesce-charges [#::charge{:credit-card #::credit-card{:id "A"}
                               :amount 1.0}
                     #::charge{:credit-card #::credit-card{:id "B"}
                               :amount 2.0}
                     #::charge{:credit-card #::credit-card{:id "A"}
                               :amount 3.0}])

  (buy-coffee #::credit-card{:id "A"})

  (buy-coffees #::credit-card{:id "A"} 3)
  )
