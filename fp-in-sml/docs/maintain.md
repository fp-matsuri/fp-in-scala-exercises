# 保守者向けの情報

演習の進め方は [README.md](../README.md) にあります．

簡単な SML 入門は [sml-primer.md](sml-primer.md) にあります．

## ファイルの配置

| パス | 内容 |
| --- | --- |
| `lib/` | `Stub`, `Pbt`, `Test` と `lib.mlb` / `lib.cm` |
| `src/chNN_<章>/XXX.sig` | 章の API (exercises / answers 共通) |
| `src/chNN_<章>/exercises/XXX.sml` | 演習 (未実装) |
| `src/chNN_<章>/answers/XXX.sml` | 解答 |
| `test/chNN_<章>/XXXTest.sml` | テスト |
| `build/exercises.{mlb,cm}` | 演習側の集約 |
| `build/answers.{mlb,cm}` | 解答側の集約 |
| `Main.sml` | MLton のエントリ (`Test.run`, CM ビルドには含めない) |
| `Makefile`, `flake.nix`, `millet.toml` | ビルドと開発環境 |
| `docs/` | この文書と `sml-primer.md` |

`build/` が同じ `*.sig` に対して `exercises/` と `answers/` のどちらを取り込むか切り替えます．

## 章の追加

収録方針は [README の収録内容](../README.md#収録内容) に従います．

1. `src/chNN_*/XXX.sig` を定義する
2. `exercises/XXX.sml` と `answers/XXX.sml` を書く ([Stub.todo](#stubtodo))
3. `test/chNN_*/XXXTest.sml` を書く ([テストの書き方](#テストの書き方))
4. `build/exercises.mlb`，`build/answers.mlb`，`build/exercises.cm`，`build/answers.cm` に追加する
5. [検証](#検証) に従って `make ...` による MLton / SML/NJ の結果を確認する (SML コードを編集したなら [整形](#整形) も)
6. [README の章一覧](../README.md#章の一覧) を更新する

### Stub.todo

`Stub.todo ()` を `val` の右辺に置くとモジュール読込で評価されて落ちます．`fun` の本体か，遅延されるコンテキストに置いてください．

値のプレースホルダ (e.g. モノイドの `empty`) は無害な値にしておき，未実装の検出は `combine` など関数側の `todo` に任せます．(第10章)

## テストの書き方

`lib/Test.sml` がテストの実行基盤です．各 `*Test.sml` はロード時に `Test.register` で登録し，`Main.sml` (MLton) または `nj-test` / `nj-answers` (SML/NJ) 経由で `Test.run ()` が実行されます．`Test.register` の登録は `structure` の中に書くようにします．

| API | 用途 |
| --- | --- |
| `Test.assertEqual` | 等値型 (`''a`) |
| `Test.assertEqualBy` | `real`，`:>` で隠した型など |
| `Test.forAll` + `lib/Pbt.sml` | 第8章より前のプロパティテスト |
| 章内の `Gen` / `Prop` | 第8章以降 (`Pbt` とは別実装) |

テスト名は `chNN ...` のように章番号を含めると，`make test CH=ch03` で絞れます．(`CH` はテスト名の部分一致)

## 処理系ごとの注意点

このリポジトリは MLton (`make test`，`build/*.mlb`) と SML/NJ (`nj-test`，`build/*.cm`) の両方でビルドできる状態にします．

### MLton

`build/*.mlb` に `ann "allowExtendedTextConsts true"` (UTF-8 文字列リテラル) を付けています．

既定の `word` は 32bit なので，大きなワード定数は `Word64.word` と注釈して `Pbt.int` の範囲も小さくしています．

### SML/NJ

`lib/lib.cm` は `Library` ではなく `Group` にします．`Library` だと `Stub` / `Test` が include 先から参照できません．

CM は `.sml` 1ファイルにつきトップレベルで `structure` を定義していることを求めます．([テストの書き方](#テストの書き方))

## 検証

PR の前に次を通します．CI も同じです．

```bash
nix develop --command make answers
nix develop --command make test
nix develop --command make nj-answers
nix develop --command make nj-test
```

`answers` / `nj-answers` は全テストの `ok` を期待します．`test` / `nj-test` は `FAIL` が無いことを期待します．演習側の未実装項目は `todo` 表示で問題ありません．

CI のワークフローは [`.github/workflows/fp-in-sml.yml`](../../.github/workflows/fp-in-sml.yml) にあります．

## 整形

[`make fmt`](../Makefile) でコードを整形します．CI には含まれません．

対象は `build/exercises.mlb` と `build/answers.mlb` に列挙された `.sig` / `.sml` です．`.mlb` に未登録のものは対象外です．`smlfmt --force` で上書きしています．

`SMLFMT` 変数でコマンドを上書きできます．
