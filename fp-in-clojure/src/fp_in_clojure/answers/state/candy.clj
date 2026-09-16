(ns fp-in-clojure.answers.state.candy
  (:require
   [clojure.spec.alpha :as s]
   [fp-in-clojure.answers.state.candy.machine :as-alias machine]
   [fp-in-clojure.answers.state.state :as state]))

;; Exercise 6.11: Stateを用いて以下のルールを満たすキャンディ販売機の振る舞いをシミュレートする関数 `simulate-machine` を実装せよ。
;; `simulate-machine` は入力リストを受け取って販売機の最終的なコインの枚数とキャンディの個数のペアを返す。
;; ルール:
;;   - 販売機がロックされている(`locked? = true`)とき、ノブを回し(:turn)ても販売機は反応しない
;;   - 販売機がロックされている(`locked? = true`)とき、コインを投入する(:coin)と販売機のロックが外れてコインが1枚増える
;;   - 販売機がロックされていない(`locked? = false`)とき、ノブを回す(:turn)と販売機のロックが掛かってキャンディが1個減る
;;   - 販売機がロックされていない(`locked? = false`)とき、コインを投入し(:coin)ても販売機は反応しない
;;   - 販売機にキャンディが残っていない(`candies = 0`)とき、コインを投入し(:coin)てもノブを回し(:turn)ても販売機は反応しない

(def input #{:coin :turn})
(s/def ::machine/locked? boolean?)
(s/def ::machine/candies nat-int?)
(s/def ::machine/coins nat-int?)

(s/def ::machine/machine
  (s/keys :req [::machine/locked? ::machine/candies ::machine/coins]))

(s/fdef update-machine
  :args (s/cat :m ::machine/machine
               :i input)
  :ret ::machine/machine)

;; NOTE: 値による条件分岐を整理するためにマルチメソッドを利用している
;; ref. https://clojure.org/reference/multimethods
(defmulti ^:private update-machine
  (fn [machine input]
    (when-not (zero? (::machine/candies machine))
      (-> machine
          (select-keys [::machine/locked?])
          (assoc :input input)))))

(defmethod update-machine :default [m _] m)
(defmethod update-machine {:input :coin ::machine/locked? false} [m _] m)
(defmethod update-machine {:input :turn ::machine/locked? true} [m _] m)

(defmethod update-machine {:input :coin ::machine/locked? true} [m _]
  (-> m
      (assoc ::machine/locked? false)
      (update ::machine/coins inc)))

(defmethod update-machine {:input :turn ::machine/locked? false} [m _]
  (-> m
      (assoc ::machine/locked? true)
      (update ::machine/candies dec)))

;; Scala風の型表記: `simulate-machine: (inputs: Sequence[Input]) => State[Machine, (NatInt, NatInt)]`
(s/fdef simulate-machine
  :args (s/cat :inputs (s/coll-of input))
  :ret state/state?)

(defn simulate-machine [inputs]
  (->> inputs
       (state/traverse (comp state/modify (fn [input] #(update-machine % input))))
       (state/flat-map (fn [_]
                         (state/map (juxt ::machine/coins ::machine/candies)
                                    (state/get))))))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (state/run-state #::machine{:locked? true :candies 0 :coins 10} (simulate-machine [:coin]))
  (state/run-state #::machine{:locked? true :candies 0 :coins 10} (simulate-machine [:turn]))
  (state/run-state #::machine{:locked? false :candies 0 :coins 10} (simulate-machine [:coin]))
  (state/run-state #::machine{:locked? false :candies 0 :coins 10} (simulate-machine [:turn]))
  (state/run-state #::machine{:locked? true :candies 5 :coins 10} (simulate-machine [:coin]))
  (state/run-state #::machine{:locked? true :candies 5 :coins 10} (simulate-machine [:turn]))
  (state/run-state #::machine{:locked? false :candies 5 :coins 10} (simulate-machine [:coin]))
  (state/run-state #::machine{:locked? false :candies 5 :coins 10} (simulate-machine [:turn]))
  (state/run-state #::machine{:locked? true :candies 5 :coins 10} (simulate-machine [:coin :turn]))
  )
