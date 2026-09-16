(ns fp-in-clojure.exercises.state.state
  (:refer-clojure :exclude [get map sequence set])
  (:require
   [clojure.spec.alpha :as s]))

;; Scala風の型表記: `State[S, A](f: S => (A, S))`
(defrecord State [f])

(s/fdef state?
  :args (s/cat :x any?)
  :ret boolean?)

(defn state? [x]
  (instance? State x))

;; Scala風の型表記: `run-state: (s0: S, sa: State[S, A]) => (A, S)`
(s/fdef run-state
  :args (s/cat :s0 any?
               :sa state?)
  :ret (s/tuple any? any?))

(defn run-state [s0 sa]
  (let [{:keys [f]} sa]
    (f s0)))

;; Exercise 6.10: 関数 `map`, `map2`, `flat-map` を実装せよ。
;; また、関数 `unit`, `sequence`, `traverse` を実装せよ。

(s/fdef flat-map
  :args (s/cat :f ifn?
               :sa state?)
  :ret state?)

(defn flat-map [f sa]
  ;; TODO
  )

(s/fdef unit
  :args (s/cat :a any?)
  :ret state?)

(defn unit [a]
  ;; TODO
  )

(s/fdef map
  :args (s/cat :f ifn?
               :sa state?)
  :ret state?)

(defn map [f sa]
  ;; TODO
  )

(s/fdef map2
  :args (s/cat :f ifn?
               :sa state?
               :sb state?)
  :ret state?)

(defn map2 [f sa sb]
  ;; TODO
  )

(s/fdef sequence
  :args (s/cat :sas (s/coll-of state?))
  :ret state?)

(defn sequence [sas]
  ;; TODO
  )

(s/fdef traverse
  :args (s/cat :f ifn?
               :xs coll?)
  :ret state?)

(defn traverse [f xs]
  ;; TODO
  )

;; Scala風の型表記: `get: Unit => State[S, S]`
(s/fdef get
  :args (s/cat)
  :ret state?)

(defn get []
  (->State (fn [s] [s s])))

;; Scala風の型表記: `set: (s: S) => State[S, Unit]`
(s/fdef set
  :args (s/cat :s any?)
  :ret state?)

(defn set [s]
  (->State (fn [_] [nil s])))

;; Scala風の型表記: `modify: (f: s -> s) => State[S, Unit]`
(s/fdef modify
  :args (s/cat :f ifn?)
  :ret state?)

(defn modify [f]
  (flat-map (comp set f) (get)))

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (run-state 42 (->State (fn [s] [:truth s])))

  (run-state 42 (map name (->State (fn [s] [:truth s]))))

  (run-state 42 (map2 #(vector %1 :or %2) (->State (fn [s] [:truth s])) (->State (fn [s] [:falsity s]))))

  (run-state 42 (flat-map #(unit [% %]) (->State (fn [s] [:truth s]))))

  (run-state 42 (unit :truth))

  (run-state 42 (sequence [(->State (fn [s] [:truth s])) (->State (fn [s] [:falsity s]))]))
  (run-state 42 (sequence []))

  (run-state 42 (traverse unit [:truth :falsity]))
  (run-state 42 (traverse unit []))

  (run-state 42 (get))

  (run-state 42 (set 21))

  (run-state 42 (modify #(* % 2)))
  )
