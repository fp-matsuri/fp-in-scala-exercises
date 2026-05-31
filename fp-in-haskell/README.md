# fp-in-haskell

FP in Scala演習問題の[Haskell](https://www.haskell.org/)版

## 必要なツール

- ビルドツール: [GHC](https://www.haskell.org/ghc/) (コマンド: `ghc`) / [Cabal](https://www.haskell.org/cabal/) (コマンド: `cabal`)

- [optional] リンター: [HLint](https://github.com/ndmitchell/hlint) (コマンド: `hlint`)

- [optional] フォーマッター: [Fourmolu](https://github.com/fourmolu/fourmolu) (コマンド: `fourmolu`)

## 使い方

### REPL

[cabal](https://www.haskell.org/cabal/) から REPL が利用できる。

```shell
make repl
```

```haskell
-- 関数を呼び出す(例)
ghci> import FpInHaskell.Answers.GettingStarted
ghci> factorial 5
120

-- 関数の型を確認(例)
ghci> :t factorial
factorial :: Int -> Int
```

### テスト

```shell
make test
```

### リント

リンターとして[HLint](https://github.com/ndmitchell/hlint) (コマンド: `hlint`)が利用できる。

```shell
make lint
```

### フォーマット

フォーマッターとして[Fourmolu](https://github.com/fourmolu/fourmolu) (コマンド: `fourmolu`)が利用できる。

```shell
# フォーマットのチェック
make format-check
# フォーマットの修正
make format
```

## プロジェクト構成

```
.
├── Makefile                           # ビルド・テスト・リント・フォーマットのターゲット
├── README.md                          
├── hello.cabal                        # Cabal プロジェクト設定
├── Setup.hs
└── src
    └── FpInHaskell
        ├── Answers                    # 解答例
        │   └── GettingStarted.hs
        └── Exercises                  # 演習問題
            └── GettingStarted.hs
└── test
    ├── GettingStartedSpec.hs          # テスト仕様
    ├── Main.hs
    └── FpInHaskell
        └── Test
            └── Common.hs              # テスト用ユーティリティ
```
