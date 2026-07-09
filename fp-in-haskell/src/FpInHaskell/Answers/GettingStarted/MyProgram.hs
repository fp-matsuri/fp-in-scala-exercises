module FpInHaskell.Answers.GettingStarted.MyProgram (
    abs,
    factorial,
    fib,
    formatResult,
) where

import Prelude hiding (abs)

-- Prelude は自動で読み込まれる標準ライブラリで、そこにはすでに `abs` という関数がある。
-- 同じ名前で自分の関数を定義するため、ファイル冒頭の `import Prelude hiding (abs)` で
-- Prelude 側の `abs` を読み込み対象から外している
abs :: Int -> Int
abs n = if n < 0 then -n else n

-- ローカルな末尾再帰関数を使った factorial の定義
factorial :: Int -> Int
factorial n = go n 1
  where
    go n' acc = if n' <= 0 then acc else go (n' - 1) (n' * acc)

-- Exercise 2.1: n番目のフィボナッチ数を計算する関数 `fib` を定義せよ。
fib :: Int -> Int
fib n = go n 0 1
  where
    go n' current next = if n' <= 0 then current else go (n' - 1) next (current + next)

-- `formatAbs` と `formatFactorial` を一般化して、_関数_ をパラメータとして受け取るようにする
formatResult :: String -> Int -> (Int -> Int) -> String
formatResult name n f = "The " ++ name ++ " of " ++ show n ++ " is " ++ show (f n) ++ "."
