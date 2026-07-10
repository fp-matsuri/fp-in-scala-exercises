(ns fp-in-clojure.exercises.data-structures.tree
  (:refer-clojure :exclude [map])
  (:require
   [clojure.spec.alpha :as s]))

;; NOTE: ここでは `Leaf` または `Branch` レコードによってツリー(二分木)を定義している。
;; ref. https://clojure.org/reference/datatypes

(defrecord Leaf [value])
(defrecord Branch [left right])

(s/fdef leaf?
  :args (s/cat :x any?)
  :ret boolean?)

(defn leaf? [x]
  (instance? Leaf x))

(s/fdef branch?
  :args (s/cat :x any?)
  :ret boolean?)

(defn branch? [x]
  (and (instance? Branch x)
       ((some-fn leaf? branch?) (:left x))
       ((some-fn leaf? branch?) (:right x))))

(s/fdef tree?
  :args (s/cat :x any?)
  :ret boolean?)

(defn tree? [x]
  (or (leaf? x)
      (branch? x)))

(s/def tree? tree?)

(s/fdef size
  :args (s/cat :t tree?)
  :ret int?)

(defn size [t]
  (if (leaf? t)
    1
    (+ (-> t :left size)
       1
       (-> t :right size))))

;; Exercise 3.25: ツリーのリーフの最大値を計算する拡張メソッド `maximum` を定義せよ。

(s/fdef maximum
  :args (s/cat :t tree?)
  :ret any?)

(defn maximum [t]
  ;; TODO
  )

;; Exercise 3.26: ツリーの深さを計算するメソッド `depth` を定義せよ。深さは、ルートから最も遠いリーフまでのパスの長さである。

(s/fdef depth
  :args (s/cat :t tree?)
  :ret int?)

(defn depth [t]
  ;; TODO
  )

;; Exercise 3.27: ツリーの各リーフに関数 `f` を適用するメソッド `map` を定義せよ。

(s/fdef map
  :args (s/cat :f ifn?
               :t tree?)
  :ret tree?)

(defn map [f t]
  ;; TODO
  )

;; Exercise 3.28: ツリーのリーフの値を変換する関数 `f` とブランチの左右の値をまとめる関数 `g` を受け取ってツリーを畳み込むメソッド `fold` を定義せよ。
;; また、 `fold` を用いて `size` 、 `depth` 、 `map` 、 `maximum` を定義せよ。

(s/fdef fold
  :args (s/cat :f ifn?
               :g ifn?
               :t tree?)
  :ret any?)

(defn fold [f g t]
  ;; TODO
  )

(s/fdef size-via-fold
  :args (s/cat :t tree?)
  :ret int?)

(defn size-via-fold [t]
  ;; TODO
  )

(s/fdef depth-via-fold
  :args (s/cat :t tree?)
  :ret int?)

(defn depth-via-fold [t]
  ;; TODO
  )

(s/fdef map-via-fold
  :args (s/cat :f ifn?
               :t tree?)
  :ret tree?)

(defn map-via-fold [f t]
  ;; TODO
  )

(s/fdef maximum-via-fold
  :args (s/cat :t tree?)
  :ret any?)

(defn maximum-via-fold [t]
  ;; TODO
  )

(comment
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  (size (->Leaf 2))
  (size (->Branch (->Leaf 2)
                  (->Leaf 4)))
  (size (->Branch (->Leaf 1)
                  (->Branch (->Leaf 4)
                            (->Leaf 2))))

  (maximum (->Leaf 2))
  (maximum (->Branch (->Leaf 2)
                     (->Leaf 4)))
  (maximum (->Branch (->Leaf 1)
                     (->Branch (->Leaf 4)
                               (->Leaf 2))))

  (depth (->Leaf 2))
  (depth (->Branch (->Leaf 2)
                   (->Leaf 4)))
  (depth (->Branch (->Leaf 1)
                   (->Branch (->Leaf 4)
                             (->Leaf 2))))

  (map #(* % %) (->Leaf 2))
  (map #(* % %) (->Branch (->Leaf 2)
                          (->Leaf 4)))
  (map #(* % %) (->Branch (->Leaf 1)
                          (->Branch (->Leaf 4)
                                    (->Leaf 2))))

  (size-via-fold (->Leaf 2))
  (size-via-fold (->Branch (->Leaf 2)
                           (->Leaf 4)))
  (size-via-fold (->Branch (->Leaf 1)
                           (->Branch (->Leaf 4)
                                     (->Leaf 2))))
  (depth-via-fold (->Leaf 2))
  (depth-via-fold (->Branch (->Leaf 2)
                            (->Leaf 4)))
  (depth-via-fold (->Branch (->Leaf 1)
                            (->Branch (->Leaf 4)
                                      (->Leaf 2))))
  (map-via-fold #(* % %) (->Leaf 2))
  (map-via-fold #(* % %) (->Branch (->Leaf 2)
                                   (->Leaf 4)))
  (map-via-fold #(* % %) (->Branch (->Leaf 1)
                                   (->Branch (->Leaf 4)
                                             (->Leaf 2))))
  (maximum-via-fold (->Leaf 2))
  (maximum-via-fold (->Branch (->Leaf 2)
                              (->Leaf 4)))
  (maximum-via-fold (->Branch (->Leaf 1)
                              (->Branch (->Leaf 4)
                                        (->Leaf 2))))
  )
