# fp-in-scala

FP in Scala演習問題の[Scala](https://scala-lang.org/)版

## 必要なツール

- ビルドツール: [sbt](https://www.scala-sbt.org/) (コマンド: `sbt`)

- [optional] リンター: [Scalafix](https://github.com/scalacenter/scalafix) (コマンド: `scalafix`)

- [optional] フォーマッター: [Scalafmt](https://github.com/scalameta/scalafmt) (コマンド: `scalafmt`)

## 使い方

### sbtコマンドの実行(共通)

以下の2通りの実行方法があるが、普段使いではsbtシェルからコマンド実行したほうが(コマンド実行のたびに起動し直すオーバーヘッドを避けられるため)快適。

- [推奨] sbtシェルを起動してコマンドを実行する([インタラクティブモード](https://www.scala-sbt.org/1.x/docs/Running.html#sbt+shell)):

    ```shell
    sbt
    sbt:fpinscala> {コマンド}
    ```

- sbtのコマンドを直接実行する([バッチモード](https://www.scala-sbt.org/1.x/docs/Running.html#Batch+mode)):

    ```shell
    sbt {コマンド名}
    ```

### REPL

[sbt](https://www.scala-sbt.org/) (設定ファイル: [build.sbt](build.sbt))からREPLが利用できる。

```shell
sbt
# REPLの起動
sbt:fpinscala> console
```

```scala
// 式を評価する(例)
scala> 1 + 2
val res0: Int = 3

// `import` で別のパッケージに定義されているものを非完全修飾名で参照する(例)
scala> import fpinscala.exercises.gettingstarted.MyProgram

scala> LazyList.from(0).map(MyProgram.factorial).take(10).toList
val res1: List[Int] = List(1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880)
```

### テスト

```shell
sbt
# 全テストの実行
sbt:fpinscala> test  # またはシェルから make test
# 特定のパッケージ内のテストの実行(例)
sbt:fpinscala> testOnly fpinscala.exercises.gettingstarted.*
# ワイルドカード指定でマッチするテストの実行(例)
sbt:fpinscala> testOnly *gettingstarted*
# 特定のテストのみの実行(例)
sbt:fpinscala> testOnly fpinscala.exercises.gettingstarted.GettingStartedSuite
# 前回失敗した/未実行のテストのみ実行
sbt:fpinscala> testQuick
```

### リント

リンターとして[Scalafix](https://github.com/scalacenter/scalafix) (設定ファイル: [.scalafix.conf](.scalafix.conf))が利用できる。

```shell
# すべてのリンター(※フォーマッターを含む)でのリント
make lint
# Scalafixでのリント
scalafix --check src  # または make scalafix-lint
```

### フォーマット

フォーマッターとして[Scalafmt](https://github.com/scalameta/scalafmt) (設定ファイル: [.scalafmt.conf](.scalafmt.conf))が利用できる。

```shell
# フォーマットのチェック
scalafmt --check src  # または make scalafmt-check
# フォーマットの修正
scalafmt src  # または make scalafmt-fix
```

## プロジェクト構成

```shell
tree -L 5 --gitignore
.
├── build.sbt  # sbtのプロジェクト設定
├── Makefile
├── project
│   ├── build.properties  # sbtのバージョン指定
│   └── plugins.sbt  # sbtのプラグイン設定
├── README.md
└── src
    ├── main  # ソースコード
    │   └── scala
    │       └── fpinscala
    │           ├── answers  # 解答例
    │           └── exercises  # 演習問題
    └── test  # テストコード
        └── scala
            └── fpinscala
                └── exercises  # 演習問題に対するテスト
```
