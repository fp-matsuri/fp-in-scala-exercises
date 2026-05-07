
- 「必要なツール」セクション
    - 開発/実行に必要なツールの名前/公式ページURLとそのコマンドの列挙
        - プロジェクト管理/ビルドツール、リンター、フォーマッターなど
    - ⚠️ ツールのインストール手順は記載不要
- 「使い方」セクション
    - REPL: コマンドラインからの起動方法と利用例
    - テスト/リント/フォーマット: コマンドラインからの実行方法
- 「プロジェクト構成」セクション
    - プロジェクトのルート階層に配置されている主なディレクトリ/ファイルについての簡単な説明(`tree` コマンドの出力をコメント補足するなど)

# fp-in-ocaml

FP in Scala演習問題の[OCaml](https://ocaml.org/)移植版

## 必要なツール

- 公式コンパイラ/ランタイム: [OCaml](https://ocaml.org/) (コマンド: `ocaml`, `ocamlfind` など) — 5.4 以降
- ビルドシステム: [Dune](https://dune.build/) (コマンド: `dune`) — 3.20 以降

依存ライブラリは [`dune-project`](dune-project) で宣言し、[Dune Package Management](https://dune.readthedocs.io/en/stable/package-management.html) (`dune pkg lock`) によって `dune.lock/` 配下にロックファイルが生成される。

- [optional] REPL: [utop](https://github.com/ocaml-community/utop) (コマンド: `utop`)
- [optional] フォーマッター: [ocamlformat](https://github.com/ocaml-ppx/ocamlformat) (設定ファイル: [.ocamlformat](.ocamlformat))
- [optional] LSP: [ocaml-lsp](https://github.com/ocaml/ocaml-lsp)

ツールはそれぞれ以下のコマンドからインストールする。

```shell
dune tools install utop
dune tools install ocamlformat
dune tools install ocamllsp
```

## 使い方

### REPL

[Dune](https://dune.build/) 経由で [utop](https://github.com/ocaml-community/utop) を起動できる。

```shell
# 演習モジュールを読み込んだ状態で utop を起動
dune utop ./exercises
```

```ocaml
(* 式を評価する *)
utop # 1 + 2 + 3 ;;
- : int = 6
(* モジュール経由で関数を呼び出す *)
utop # Getting_started.My_program.factorial 10 ;;
- : int = 3628800
(* `open` で名前空間を取り込んでから呼び出す *)
utop # open Getting_started.My_program ;;
utop # List.init 10 factorial ;;
- : int list = [1; 1; 2; 6; 24; 120; 720; 5040; 40320; 362880]
```

### テスト

テストランナーとして [alcotest](https://github.com/mirage/alcotest)、PBT のためのライブラリとして [qcheck](https://github.com/c-cube/qcheck) を利用している。

```shell
# 全テストの実行
dune test
# 特定のテスト実行ファイルのみ実行
dune exec test/my_program_test.exe
```

### フォーマット

フォーマッターとして [ocamlformat](https://github.com/ocaml-ppx/ocamlformat) (設定ファイル: [.ocamlformat](.ocamlformat))が利用できる。
デフォルト設定の場合でも空ファイルが必要。

```shell
# フォーマットのチェック
dune build @fmt
# フォーマットの修正
dune fmt
```

### 依存ライブラリの更新

```shell
# dune-project の depends を変更したあとに実行してロックファイルを更新
dune pkg lock
```

## プロジェクト構成

```
tree -L 3 -I '_build|dune.lock|_opam'
.
├── README.md
├── dune-project # dune (ビルドシステム) のためのプロジェクト定義
├── answers # 解答例
│   ├── dune # dune (ビルドシステム) のパッケージ定義など
│   ├── getting_started.ml
│   └── ...
├── exercises # 演習問題
│   ├── dune
│   ├── getting_started.ml
│   └── ...
└── test # 演習問題のテスト
    ├── dune
    ├── getting_started_test.ml
    └── ...
```
