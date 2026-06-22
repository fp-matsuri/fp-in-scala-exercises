# fp-in-scala-exercises

FP in Scala ([*Functional Programming in Scala, Second Edition*](https://www.manning.com/books/functional-programming-in-scala-second-edition), 第1版訳書[『Scala関数型デザイン＆プログラミング』](https://book.impress.co.jp/books/1114101091))ベースの関数型プログラミング演習問題

cf. FP in Scalaの公式リポジトリ: https://github.com/fpinscala/fpinscala

## 問題集の構成

- Part 1: Introduction to functional programming (関数型プログラミングの基礎)
    - Chapter 1: What is functional programming? (関数型プログラミングとは)
        - `introduction` ※演習問題(exercises)なし
    - Chapter 2: Getting started with functional programming in Scala (Scala関数型プログラミングの準備)
        - `gettingstarted`
    - Chapter 3: Functional data structures (関数型プログラミングのデータ構造)
        - `datastructures`
    - Chapter 4: Handling errors without exceptions (例外を使わないエラー処理)
        - `errorhandling`
    - Chapter 5: Strictness and laziness (正格と遅延)
        - `laziness`
    - Chapter 6: Purely functional state (純粋関数型の状態)
        - `state`
- Part 2: Functional design and combinator libraries (関数型デザインとコンビネータライブラリ)
    - Chapter 7: Purely functional parallelism (純粋関数型の並列処理)
        - `parallelism`
    - Chapter 8: Property-based testing (プロパティベースのテスト)
        - `testing`
    - Chapter 9: Parser combinators (パーサーコンビネータ)
        - `parsing`
- Part 3: Common structures in functional design (関数型デザインに共通する構造)
    - Chapter 10: Monoids (モノイド)
        - `monoids`
    - Chapter 11: Monads (モナド)
        - `monads`
    - Chapter 12: Applicative and traversable functors (アプリカティブファンクタとトラバーサブルファンクタ)
        - `applicative`
- Part 4: Effects and I/O (作用とI/O)
    - Chapter 13: External effects and I/O (外部作用とI/O)
        - `iomonad`
    - Chapter 14: Local effects and mutable state (局所作用とミュータブルな状態)
        - `localeffects`
    - Chapter 15: Stream processing and incremental I/O (ストリーム処理とインクリメンタルI/O)
        - `streamingio`

## 利用者向けガイド

### Dev Container を使う（推奨）

このリポジトリは Dev Container に対応している。以下のいずれかの方法で、ツールのインストール不要ですぐに演習を始められる。

**VS Code で開く場合**

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) と VS Code の [Dev Containers 拡張](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) をインストール
2. このリポジトリをクローン
3. VS Code でリポジトリを開き、右下の通知または左下の `><` メニューから「コンテナーで再度開く」を選択

**GitHub Codespaces で開く場合**

GitHub のリポジトリページから「Code → Codespaces → Create codespace」を選択するだけで使える。

### ローカル環境で使う

Dev Container を使わない場合、各言語ディレクトリ配下の README.md を参照。

## 問題作成者向けガイド

[CONTRIBUTING.md](CONTRIBUTING.md)を参照
