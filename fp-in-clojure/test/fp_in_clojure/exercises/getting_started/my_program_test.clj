(ns fp-in-clojure.exercises.getting-started.my-program-test
  (:require
   [clojure.spec.alpha :as s]
   [clojure.test :as t]
   [clojure.test.check.clojure-test :as tc]
   [clojure.test.check.properties :as prop]
   ;; 解答例
   ;; NOTE: `#_` の直後のフォームは読み込み(read)時にスキップされる
   ;; ref. https://clojure.org/guides/weird_characters#_discard
   #_[fp-in-clojure.answers.getting-started.my-program :as sut]
   [fp-in-clojure.exercises.common :as common]
   [fp-in-clojure.exercises.getting-started.my-program :as sut]
   [fp-in-clojure.test-helper :as test-helper]))

(t/use-fixtures
  :once (test-helper/instrument-specs *ns*))

;; NOTE: test.checkによるプロパティベーステスト(PBT)のテストケース
;; ref. https://github.com/clojure/test.check
(tc/defspec factorial-test 1000
  ;; NOTE: clojure.specの仕様(spec)はtest.checkのジェネレータとして利用できる
  ;; ref. https://clojure.org/guides/spec#_generators
  (prop/for-all [n (s/gen (s/and pos-int?
                                 #(<= % 1000)))]
    (= (apply *' (range 1 (inc n)))
       (sut/factorial n))))

(tc/defspec fib-test 1000
  (prop/for-all [i (s/gen ::common/length-of-fibonacci-seq)]
    (= (nth common/the-first-21-fibonacci-numbers i)
       (sut/fib i))))
