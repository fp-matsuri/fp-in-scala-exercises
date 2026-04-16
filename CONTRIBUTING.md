# 問題作成ガイド

## 前提

### 本問題集の狙いと位置付け

書籍[*Functional Programming in Scala, Second Edition*](https://www.manning.com/books/functional-programming-in-scala-second-edition) (通称FP in Scala)の公式リポジトリ[fpinscala](https://github.com/fpinscala/fpinscala)で公開されている演習問題とその解答例をScala以外の言語でも提供し、(純粋)関数型プログラミングというプログラミングスタイルでよく登場する概念や機能、コード設計のパターンに触れられるようにする。

### ⚠️ 書籍と本家のコードの対応関係

| 書籍  | 公式リポジトリのブランチ |
|---|---|
| [*Functional Programming in Scala, Second Edition*](https://www.manning.com/books/functional-programming-in-scala-second-edition) | [second-edition](https://github.com/fpinscala/fpinscala/tree/second-edition) (default) |
| [*Functional Programming in Scala*](https://www.manning.com/books/functional-programming-in-scala) (First Edition)<br>[『Scala関数型デザイン＆プログラミング』](https://book.impress.co.jp/books/1114101091) | [first-edition](https://github.com/fpinscala/fpinscala/tree/first-edition) |

本問題集はSecond Editionのソースコードを前提に作成する。

作成時に書籍は必須ではないと想定しているが、(First Editionの原書/訳書も含めて)手元にあると例題や問題の趣旨や部/章を経て段階的に抽象化していく過程が理解しやすいかも。

## 新規言語の追加方法

1. [必須] 本リポジトリのルートに `fp-in-{言語名(小文字のみ表記)}` という名前のディレクトリを追加し、配下に実装言語で標準的と考えられるプロジェクト管理/ビルドツールによる構成のプロジェクトを配置する

ℹ️ ソースコード/テストコード用のディレクトリやモジュール/パッケージの配置と命名のスタイルは実装言語で標準的なものを優先してよい。

⚠️ 以降の作業はこのディレクトリ配下をプロジェクトルートとして行う。

2. [必須] 実装言語用の `.gitignore` を追加する

実装言語で通常Gitリポジトリに含めないものが適切に除外されるようにする([github/gitignore](https://github.com/github/gitignore)のテンプレートがあれば活用する)。

3. [必須] 演習問題[exercises](https://github.com/fpinscala/fpinscala/tree/second-edition/src/main/scala/fpinscala/exercises)と解答例[answers](https://github.com/fpinscala/fpinscala/tree/second-edition/src/main/scala/fpinscala/answers)の内容を実装言語向けに移植する

ℹ️ 実装言語の(標準/サードパーティライブラリで見られるような)自然なコードになるように、ファイル分割の単位、関数の命名スタイルや引数の順序などを適宜変更してよい。

ℹ️ 言語の特性により本家Scala版と同等の問題と解答を考えるのが現実的に困難または無意味と思われる場合には、説明コメントを添えて設問を省略する、もしくは代わりに類似の問題と解答例を示してよい。

4. [任意] exercises, answersの移植版に補足説明/解説のコードコメントを追加する

実装言語固有の考慮要素など、学習者に有益と思われる補足があればコメントで示す。

5. [任意] [exercisesに対するテストコード](https://github.com/fpinscala/fpinscala/tree/second-edition/src/test/scala/fpinscala/exercises)を実装言語向けに移植する

⚠️ テストコードは(answersではなく) exercisesをテスト対象として実装すること(answersの解答例を手もとで仮反映してすべてのテストケースをパスすることを確認する)。

ℹ️ 本家Scala版では独自実装されたproperty-based testing (PBT)ライブラリが使われているが、PBTのテストコードを再現する場合には実装言語での標準的なPBTライブラリを利用してよい(そもそも標準的なPBTライブラリがない場合にはexample-based testingのテストケースで代替してよい)。

6. [任意] フォーマッターやリンターを導入して適用する

実装言語でよく使われる静的解析ツールがあれば全体に適用する。

ℹ️ 利用者もコマンドライン実行しやすいようにMakefileやビルド設定ファイルなどにスクリプトとしてまとめておくことを推奨する。

7. [必須] `README.md` に利用者向けの説明を記載する

- 「必要なツール」セクション
    - 開発/実行に必要なツールの名前/公式ページURLとそのコマンドの列挙
        - プロジェクト管理/ビルドツール、リンター、フォーマッターなど
    - ⚠️ ツールのインストール手順は記載不要
- 「使い方」セクション
    - REPL: コマンドラインからの起動方法と利用例
    - テスト/リント/フォーマット: コマンドラインからの実行方法
- 「プロジェクト構成」セクション
    - プロジェクトのルート階層に配置されている主なディレクトリ/ファイルについての簡単な説明(`tree` コマンドの出力をコメント補足するなど)

```markdown
# fp-in-{言語名(小文字のみ表記)}

FP in Scala演習問題の{言語名}移植版

## 必要なツール

...

## 使い方

...

## プロジェクト構成

...
```

## pull requestの出し方

pull requestのテンプレートを参照。
