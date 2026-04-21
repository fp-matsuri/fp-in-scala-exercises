# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

*Functional Programming in Scala, Second Edition* (FP in Scala) の演習問題を複数言語に移植したリポジトリ。ルートに `fp-in-{言語名}/` 形式のディレクトリが並び、それぞれが独立したプロジェクトになっている。

現在の実装状況:
- **Clojure** (`fp-in-clojure/`) — 実装済み
- **Haskell** (`fp-in-haskell/`) — プレースホルダーのみ
- **Scala** (`fp-in-scala/`) — プレースホルダーのみ

各言語ディレクトリは独自のビルドツール・テスト・リンター・フォーマッターを持つ。以下のコマンドは各言語のサブディレクトリ内で実行する。

## Clojure (`fp-in-clojure/`)

### コマンド

```shell
# 全テストの実行
clj -X:test
# または
make test

# 特定の名前空間のテストの実行
clj -X:test :nses '[fp-in-clojure.exercises.getting-started.my-program-test]'

# 正規表現にマッチする名前空間のテストの実行
clj -X:test :patterns '[".+getting-started.+"]'

# 特定のテスト関数のみ実行
clj -X:test :vars '[fp-in-clojure.exercises.getting-started.my-program-test/factorial-test]'

# REPLの起動(テスト用dependenciesを含む)
clj -M:test

# 全リンターでリント
make lint

# clj-kondo のみ
clj-kondo --lint src

# Joker のみ
joker --lint --working-dir src

# フォーマットチェック
cljstyle check

# フォーマット修正
cljstyle fix
```

### アーキテクチャ

- `src/fp_in_clojure/exercises/` — 演習問題のスタブ(学習者が実装する)
- `src/fp_in_clojure/answers/` — 解答例
- `test/fp_in_clojure/exercises/` — exercises を対象としたテスト(answers ではない)

テストは `clojure.test` と `test.check` によるプロパティベーステストを使用する。`clojure.spec.alpha` のスペックはテスト実行時に `test-helper/instrument-specs` によって自動的にインストルメント化され、テスト対象の名前空間のスペックチェックが有効になる。

解答例で動作確認したい場合は、テストファイル内の `#_[fp-in-clojure.answers....]` のコメントアウト(`#_`)を外し、exercises の require をコメントアウトする。

演習の章構成は書籍に対応している:
- `getting-started` — Ch.2: 基本的なFP概念・末尾再帰・高階関数
- 以降の章(データ構造・エラー処理など)は README.md の部/章構成に対応

## 新規言語の追加

[CONTRIBUTING.md](CONTRIBUTING.md) の手順を参照。`fp-in-{言語名}/` の作成、`.gitignore` の追加、exercises/answers の移植、テスト・リンター・フォーマッターの導入、「必要なツール」「使い方」「プロジェクト構成」を含む `README.md` の作成が必要。
