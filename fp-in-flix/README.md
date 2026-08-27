# fp-in-flix

FP in Scala演習問題の[Flix](https://flix.dev/)移植版

## 必要なツール

- コマンドラインツール: [`flix` コマンド](https://flix.dev/get-started/)
    - もしくは、配布されているjarを直接利用して: `java -jar flix.jar`

## 使い方

### REPL

```shell
# REPLの起動
flix repl  # または make repl
```

```flix
// 式を評価する(例)
flix> 1 + 2
3
// `use` で別のモジュールに定義されているものを非完全修飾名で参照する(例)
// ※ `\\` はREPLでの複数行入力の開始と終了
flix> \\
> use FpInFlix.Exercises.GettingStarted.{MyProgram => M};
> DelayList.startFrom(0) |> DelayList.map(M.factorial) |> DelayList.take(10)
> \\
DelayList(1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880)
```

### テスト

コマンドラインから:

    ```shell
    # 全テストの実行
    flix test  # または make test
    ```

REPLから:

    ```flix
    flix> :test  // または :t
    ```

## プロジェクト構成

```shell
tree -L 3 --gitignore
.
├── flix.toml  # プロジェクト設定
├── Makefile
├── README.md
├── src  # ソースコード
│   ├── FpInFlix
│   │   ├── Answers  # 解答例
│   │   ├── Answers.flix
│   │   ├── Exercises  # 演習問題
│   │   └── Exercises.flix
│   └── FpInFlix.flix
└── test  # テストコード
    └── FpInFlix
        └── Exercises  # 演習問題に対するテスト
```
