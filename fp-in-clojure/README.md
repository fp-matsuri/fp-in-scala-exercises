# fp-in-clojure

FP in Scala演習問題の[Clojure](https://clojure.org/)移植版

## 必要なツール

- 公式コマンドラインツール: [Clojure CLI](https://clojure.org/reference/clojure_cli) (コマンド: `clj`, `clojure`)

- [optional] リンター:
    - [clj-kondo](https://github.com/clj-kondo/clj-kondo) (コマンド: `clj-kondo`)
    - [Joker](https://github.com/candid82/joker) (コマンド: `joker`)

- [optional] フォーマッター: [cljstyle](https://github.com/greglook/cljstyle) (コマンド: `cljstyle`)

## 使い方

### REPL

[Clojure CLI](https://clojure.org/reference/clojure_cli) (設定ファイル: [deps.edn](deps.edn))からREPLが利用できる。

Lisp系言語らしいREPLの本格的な活用方法は公式ドキュメントのガイド[Programming at the REPL](https://clojure.org/guides/repl/introduction)や「REPL駆動開発」(REPL-driven development)というキーワードで調べてみよう。

```shell
# REPLの起動(:test dependencies付き)
clj -M:test  # 単に clj ではデフォルトのdependenciesのみが読み込まれる
```

```clojure
;; 式を評価する(例)
user=> (+ 1 2 3)
6
;; `require` で別の名前空間に定義されているものを読み込む(例)
user=> (require '[fp-in-clojure.exercises.getting-started.my-program :as mp])
nil
user=> (->> (range)
            (map mp/factorial)
            (take 10))
(1 1 2 6 24 120 720 5040 40320 362880)
;; `in-ns` で現在の名前空間を切り替える(例)
user=> (in-ns 'fp-in-clojure.exercises.getting-started.my-program)
#object[clojure.lang.Namespace 0x1542af63 "fp-in-clojure.exercises.getting-started.my-program"]
fp-in-clojure.exercises.getting-started.my-program=> (factorial 10)
3628800
```

### テスト

テストランナー[cognitect-labs/test-runner](https://github.com/cognitect-labs/test-runner)を利用している。

```shell
# 全テストの実行
clj -X:test  # または make test
# 特定の名前空間のテストの実行(例)
clj -X:test :nses '[fp-in-clojure.exercises.getting-started.my-program-test]'
# 正規表現にマッチする名前空間のテストの実行(例)
clj -X:test :patterns '[".+getting-started.+"]'
# 特定のテストのみの実行(例)
clj -X:test :vars '[fp-in-clojure.exercises.getting-started.my-program-test/factorial-test]'
```

### リント

リンターとして[clj-kondo](https://github.com/clj-kondo/clj-kondo) (設定ファイル: [.clj-kondo/config.edn](.clj-kondo/config.edn))と[Joker](https://github.com/candid82/joker) (設定ファイル: [.joker](.joker))が利用できる(カバー範囲が異なるため、組み合わせることでより効果的になる)。

```shell
# すべてのリンターでのリント
make lint
# clj-kondoでのリント
clj-kondo --lint src  # または make clj-kondo-lint
# Jokerでのリント
joker --lint --working-dir src  # または make joker-lint
```

### フォーマット

フォーマッターとして[cljstyle](https://github.com/greglook/cljstyle) (設定ファイル: [.cljstyle](.cljstyle))が利用できる([The Clojure Style Guide](https://guide.clojure.style/)に相当する設定になっている)。

```shell
# フォーマットのチェック
cljstyle check  # または make cljstyle-check
# フォーマットの修正
cljstyle fix  # または make cljstyle-fix
```

## プロジェクト構成

```shell
tree -L 3
.
├── build.clj  # Clojure CLIのビルドスクリプト
├── deps.edn  # Clojure CLIのプロジェクト設定
├── Makefile
├── README.md
├── src  # ソースコード
│   └── fp_in_clojure
│       ├── answers  # 解答例
│       └── exercises  # 演習問題
└── test  # テストコード
    └── fp_in_clojure
        └── exercises  # 演習問題に対するテスト
```
