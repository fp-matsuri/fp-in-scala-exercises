;; コメント!
(ns fp-in-clojure.answers.getting-started.my-program
  "ドキュメンテーションコメント"
  (:refer-clojure :exclude [abs])
  (:require
   [clojure.spec.alpha :as s]))

;; NOTE: clojure.specによる関数に対する述語ベースの仕様(spec)。
;; 関数の実装には直接影響しないが、チェッカーやドキュメンテーションとして機能する。
;; ref. https://clojure.org/guides/spec
(s/fdef abs
  :args (s/cat :n integer?)
  :ret integer?)

(defn abs [n]
  (if (neg? n)
    (- n)
    n))

(defn- format-abs [x]
  (let [msg "The absolute value of %d is %d"]
    (format msg x (abs x))))

(defn -main [& _]
  (println (format-abs -42)))

;; ローカルな末尾再帰関数を用いた階乗の定義

(s/fdef factorial
  :args (s/cat :n integer?)
  :ret integer?)

(defn factorial [n]
  ;; NOTE: `loop` マクロによりローカルな末尾再帰を簡潔に実装できる
  ;; ref. https://clojuredocs.org/clojure.core/loop
  (loop [n n
         acc 1]
    (if (<= n 0)
      acc
      (recur (dec n)
             (*' n acc)))))

(defn factorial' [n]
  ;; NOTE: `loop` マクロを使わず、ローカルな末尾再帰関数を `letfn` マクロで定義することもできる
  ;; ref. https://clojuredocs.org/clojure.core/letfn
  (letfn [(go [n acc]
              (if (<= n 0)
                acc
                (recur (dec n)
                       (*' n acc))))]
    (go n 1)))

;; 今度は `while` ループによる `factorial` の別の実装

(s/fdef factorial2
  :args (s/cat :n integer?)
  :ret integer?)

(defn factorial2 [n]
  ;; NOTE: `volatile!` による可変な参照型を局所的に利用している
  ;; ref. https://clojuredocs.org/clojure.core/volatile!
  (let [acc (volatile! 1)
        i (volatile! n)]
    (while (pos? @i)
      (vswap! acc *' @i)
      (vswap! i dec))
    @acc))

;; Exercise 2.1: n番目のフィボナッチ数を計算する関数 `fib` を定義せよ。

(s/fdef fib
  :args (s/cat :n integer?)
  :ret integer?)

;; 0と1が数列の最初の2つの数なので、アキュムレータ(累積変数)をそこから始める。
;; 繰り返しのたびに2つの数を加えて次の数とする。
(defn fib [n]
  (loop [n n
         prev 0
         curr 1]
    (if (<= n 0)
      prev
      (recur (dec n)
             curr
             (+' prev curr)))))

;; この定義と `format-abs` はとてもよく似ている。

(defn format-factorial [n]
  (let [msg "The factorial of %d is %d."]
    (format msg n (factorial n))))

;; `format-abs` と `format-factorial` が
;; パラメータとして _関数_ を受け付けるように一般化できる。

(s/fdef format-result
  :args (s/cat :name string?
               :n integer?
               :f (s/fspec :args (s/tuple integer?)
                           :ret integer?))
  :ret string?)

(defn format-result [name n f]
  (let [msg "The %s of %d is %d."]
    (format msg name n (f n))))

;; NOTE: `comment` マクロで包まれた式は評価(eval)時に無視されるため、
;; 動作確認用の式を書き並べるために活用できる(エディタに接続したREPLでの局所評価に適している)
;; ref. https://clojuredocs.org/clojure.core/comment
(comment
  ;; NOTE: clojure.specの関数に対するチェックを有効化する
  ;; ref. https://clojure.org/guides/spec#_instrumentation_and_testing
  (require '[clojure.spec.test.alpha :as stest])
  (stest/instrument)

  ;; NOTE: 標準出力を文字列としてキャプチャする
  ;; ref. https://clojuredocs.org/clojure.core/with-out-str
  (with-out-str
    (-main))

  (abs -42)

  (format-abs -42)

  (map factorial (range 10))

  (map factorial2 (range 10))

  (map fib (range 10))

  (format-factorial 6)

  (format-result "absolute value" -42 abs)

  (format-result "factorial" 7 factorial)

  (format-result "factorial" 7 fib)
  )
