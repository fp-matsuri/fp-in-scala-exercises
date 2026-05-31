---
name: haskell-review
description: fp-in-scala 演習を Haskell へ移植したコードを規約に沿ってレビューする。移植や fp-in-haskell の編集をレビューするときに使う。
user-invocable: true
disable-model-invocation: true
model: opus
---

# fp-in-scala → Haskell 移植レビュー

変更された Haskell コードを以下の観点でレビューし、違反を該当行とともに指摘する。

- Prelude と衝突する名前は `my` 接頭辞で回避し、`import Prelude hiding` を使わない。
- 文字列整形は `show` と `++` で行い、`Text.Printf.printf` を使わない。
- 標準出力は `print*` 関数の `putStrLn` が担い、確認は ghci で行う。
- 出力メッセージは Scala 版と一致させる。
- 複数の `object` は1モジュールに集約し、同名衝突する関数は型や用途を名前に付加して区別する（例: `findFirst` 単相版 → `findFirstString`）。
- Scala の `(A, B) => C` はカリー化 `a -> b -> c` に対応づける。
- 演習関数の本体は `undefined` とし、Answers のみ実装する。
- コメントおよびテストの説明文は日本語で書く。
- 括弧の代わりに `$` を使わない。
- 型シグネチャの型変数名と完全一致する識別子を値の引数名に使わない（例: 型変数 `a` に対して値引数 `a` は不可、`as` や `x` は可）。
