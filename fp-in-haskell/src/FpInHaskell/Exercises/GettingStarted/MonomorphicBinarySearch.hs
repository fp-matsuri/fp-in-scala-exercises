module FpInHaskell.Exercises.GettingStarted.MonomorphicBinarySearch (
    findFirst,
) where

-- まずは String に特化した findFirst。理想的には任意のリスト型に対して動作するよう一般化できる。
findFirst :: String -> [String] -> Int
findFirst key ss = go ss 0
  where
    -- リストが空になったら、キーが存在しないことを示す -1 を返す。
    go [] _ = -1
    -- 先頭要素 `x` を取り出し、`key` と一致すれば現在の位置 `n` を返す。
    -- そうでなければ残りのリスト `xs` で探し続ける。
    go (x : xs) n = if x == key then n else go xs (n + 1)
