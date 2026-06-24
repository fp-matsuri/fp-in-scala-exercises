# fp-in-sml

[Functional Programming in Scala, Second Edition](https://www.manning.com/books/functional-programming-in-scala-second-edition) の演習を Standard ML (SML) で解くハンズオン教材です．

Scala や Haskell の知識は前提にしません．SML の経験が無ければ [`docs/sml-primer.md`](docs/sml-primer.md) を一読してください．

## 収録内容

- 本書の各章を SML のモジュールシステムで実装しながら学びます．
- なるべく処理系に依存しないように作ります．MLton と SML/NJ の両方で動くことを期待しています．
  - `parallelism` については，並行 API (CML など) が処理系ごとに異なるため含めません．
  - `laziness` については，標準ライブラリに遅延リストが無いので Stream をサンクで再現します．SML/NJ の拡張機能は利用しません．
- `localeffects` は ST モナドを扱わずクイックソートのみに絞ります．
  - 可変性を型に閉じ込めることが主題ですが，SML では関数内の `ref` / 配列で副作用を隠蔽するのが自然な設計です．

## 準備

| ツール | 用途 |
| --- | --- |
| [MLton](http://mlton.org/) | `make test` で演習をビルド・テスト |
| [SML/NJ](https://www.smlnj.org/) | `make repl` で対話的に試す |
| [smlfmt](https://github.com/shwestrick/smlfmt) | `make fmt` でコード整形 (必要であれば) |
| [Millet](https://github.com/azdavis/millet) | エディタ補完 (必要であれば) |

[`flake.nix`](flake.nix) で上記を揃えられます．

```bash
cd fp-in-sml
nix develop
make test
```

Homebrew を使う場合は `brew install mlton smlnj smlfmt` で入ります．

apt を使う場合は `sudo apt install -y mlton smlnj` で入ります．(`smlfmt` と Millet は別途)

## 演習の進め方

1. 章のシグネチャ `src/chNN_*/XXX.sig` で求められる関数を確認する．Basis と衝突する型やモジュール (`MyList`, `MyOption`, `MyIO` など) には `My` 接頭辞が付きます．
2. `src/chNN_*/exercises/XXX.sml` の `Stub.todo ()` を自分の実装に置き換えます．
3. `make test` でテストを実行します．

```bash
make test            # 全テスト (未実装は todo と表示)
make test CH=ch03    # 章で絞る (テスト名の部分一致)
make repl            # REPL で試す
make fmt             # smlfmt でコード整形
```

REPL を開いた場合は，以下のようにして読み込めます．

```sml
CM.make "build/exercises.cm";
Test.run ();
```

`make test` の表示は以下の通りです．

- `ok` → 正しい
- `FAIL` → 期待している結果と不一致
- `todo` → まだ `Stub.todo ()` のまま

解答例は `src/chNN_*/answers/` にあります．`make answers` で解答側のテストを確認できます (自分の実装の検証には使いません)．

## エディタ

VS Code の拡張で [Millet](https://marketplace.visualstudio.com/items?itemName=azdavis.millet) があります．

Neovim の場合は `require('lspconfig').millet.setup({})` でいけます．`millet.toml` があるので `fp-in-sml/` をルートに開いてください．

## 章の一覧

| 章 | 題材 |
| --- | --- |
| 2 | gettingstarted |
| 3 | datastructures |
| 4 | errorhandling |
| 5 | laziness |
| 6 | state |
| 8 | testing |
| 9 | parsing |
| 10 | monoids |
| 11 | monads |
| 12 | applicative |
| 13 | iomonad |
| 14 | localeffects |
| 15 | streamingio |

---

リポジトリの拡張や CI 追加など，保守者に向けた情報は [`docs/maintain.md`](docs/maintain.md) を参照してください．
