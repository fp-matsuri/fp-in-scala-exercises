(ns fp-in-clojure.exercises.state.candy-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as sgen]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.generators :as gen]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   #_[fp-in-clojure.answers.state.candy :as sut]
   #_[fp-in-clojure.answers.state.candy.machine :as-alias machine]
   #_[fp-in-clojure.answers.state.state :as state]
   [fp-in-clojure.exercises.state.candy :as sut]
   [fp-in-clojure.exercises.state.candy.machine :as-alias machine]
   [fp-in-clojure.exercises.state.state :as state]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns* 'sut))

(def ^:private gen-pos-int (s/gen (s/int-in 1 1000)))
(def ^:private gen-non-neg-int (s/gen (s/int-in 0 1000)))
(def ^:private gen-input (sgen/fmap #(if % :coin :turn) (s/gen boolean?)))
(def ^:private gen-input-list (sgen/list gen-input))

(def ^:private gen-no-candies-machine
  (gen/let [locked? (s/gen boolean?)
            coins gen-non-neg-int]
    #::machine{:locked? locked?
               :candies 0
               :coins coins}))

(def ^:private gen-locked-machine
  (gen/let [candies gen-pos-int
            coins gen-non-neg-int]
    #::machine{:locked? true
               :candies candies
               :coins coins}))

(def ^:private gen-unlocked-machine
  (gen/let [candies gen-pos-int
            coins gen-non-neg-int]
    #::machine{:locked? false
               :candies candies
               :coins coins}))

(def ^:private gen-machine
  (gen/let [locked? (s/gen boolean?)
            candies gen-pos-int
            coins gen-non-neg-int]
    #::machine{:locked? locked?
               :candies candies
               :coins coins}))

(tc/defspec simulate-machine_machine-that-is-out-of-candy-test 1000
  (prop/for-all [inputs gen-input-list
                 {::machine/keys [coins candies] :as machine} gen-no-candies-machine]
    (let [[result final-machine] (state/run-state machine (sut/simulate-machine inputs))]
      ;; 変化なし
      (and (= [coins candies] result)
           (= machine final-machine)))))

(tc/defspec simulate-machine_inserting-coin-into-locked-machine-test 1000
  (prop/for-all [{::machine/keys [coins candies] :as machine} gen-locked-machine]
    (let [[result final-machine] (state/run-state machine (sut/simulate-machine [:coin]))]
      ;; コインが1枚増え、ロックが外れる
      (and (= [(inc coins) candies] result)
           (= (-> machine
                  (update ::machine/coins inc)
                  (assoc ::machine/locked? false))
              final-machine)))))

(tc/defspec simulate-machine_turning-knob-on-locked-machine-test 1000
  (prop/for-all [{::machine/keys [coins candies] :as machine} gen-locked-machine]
    (let [[result final-machine] (state/run-state machine (sut/simulate-machine [:turn]))]
      ;; 変化なし
      (and (= [coins candies] result)
           (= machine final-machine)))))

(tc/defspec simulate-machine_inserting-coin-into-unlocked-machine-test 1000
  (prop/for-all [{::machine/keys [coins candies] :as machine} gen-unlocked-machine]
    (let [[result final-machine] (state/run-state machine (sut/simulate-machine [:coin]))]
      ;; 変化なし
      (and (= [coins candies] result)
           (= machine final-machine)))))

(tc/defspec simulate-machine_turning-knob-on-unlocked-machine-test 1000
  (prop/for-all [{::machine/keys [coins candies] :as machine} gen-unlocked-machine]
    (let [[result final-machine] (state/run-state machine (sut/simulate-machine [:turn]))]
      ;; キャンディが1個減り、ロックが掛かる
      (and (= [coins (dec candies)] result)
           (= (-> machine
                  (update ::machine/candies dec)
                  (assoc ::machine/locked? true))
              final-machine)))))

(tc/defspec simulate-machine_spend-some-coins-test 100
  (prop/for-all [{::machine/keys [coins candies] :as machine} gen-locked-machine
                 my-coins gen-pos-int]
    (let [inputs (->> [:coin :turn] (repeat my-coins) flatten)
          [result final-machine] (state/run-state machine (sut/simulate-machine inputs))
          spent-coins (min candies my-coins)]
      ;; キャンディの残数が尽きるまでに使ったコインの分だけコインの枚数が増え、キャンディの個数が減る
      (and (= [(+ coins spent-coins) (- candies spent-coins)] result)
           (= (-> machine
                  (update ::machine/coins + spent-coins)
                  (update ::machine/candies - spent-coins))
              final-machine)))))

(tc/defspec simulate-machine_empty-inputs-test 1000
  (prop/for-all [{::machine/keys [coins candies] :as machine} gen-machine]
    (let [[result final-machine] (state/run-state machine (sut/simulate-machine []))]
      ;; 変化なし
      (and (= [coins candies] result)
           (= machine final-machine)))))
