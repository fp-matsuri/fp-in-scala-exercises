module FpInHaskell.Answers.GettingStarted.PolymorphicFunctions (
    findFirst,
    isSorted,
    partial1,
    myCurry,
    myUncurry,
    compose,
) where

-- こちらは多相版の `findFirst`。探している要素かどうかをテストする関数でパラメータ化されている。
-- `String` をハードコードせず、型 `a` をパラメータとして受け取る。
-- また、特定のキーとの等値チェックをハードコードする代わりに、
-- リストの各要素をテストする関数を受け取る。
findFirst :: (a -> Bool) -> [a] -> Int
findFirst p as = go as 0
  where
    go [] _ = -1
    -- 関数 `p` が現在の要素にマッチしたら、合うものが見つかったということでリストのそのインデックスを返す。
    go (x : xs) n = if p x then n else go xs (n + 1)

-- Exercise 2.2: `[a]` がソート済みかどうかを判定する多相関数を定義せよ。
-- 第1引数 `gt` は `as` の隣接する2要素をとって最初の要素が2番目の要素より大きいかどうかを判定する述語関数。
-- リストを最後の引数にすると部分適用や関数合成がしやすい
-- 例: `isDescending = isSorted (>)` と定義しておけば、
-- `isDescending [3, 2, 1]` や `isDescending [1, 2, 3]` のように、
-- 比較関数 `>` を書き直さず異なるリストの判定に使い回せる
-- リストが第1引数だと部分適用できないため、
-- `isSorted [3, 2, 1] (>)` や `isSorted [1, 2, 3] (>)` のように毎回比較関数 `>` を書く必要がある
isSorted :: (a -> a -> Bool) -> [a] -> Bool
isSorted gt as = go as
  where
    go [] = True
    go [_] = True
    go (x : y : rest) = if gt x y then False else go (y : rest)

-- 多相関数はたいてい型によって強く制約されているため、実装がひとつしかないことがある。その例:
partial1 :: a -> (a -> b -> c) -> b -> c
partial1 x f y = f x y

-- Exercise 2.3: `myCurry` を実装せよ。
-- `->` は右結合なので、戻り値の型は `a -> (b -> c)` とも書ける。
myCurry :: ((a, b) -> c) -> a -> b -> c
myCurry f x y = f (x, y)

-- Exercise 2.4: `myUncurry` を実装せよ。
myUncurry :: (a -> b -> c) -> (a, b) -> c
myUncurry f (x, y) = f x y

-- 補足: Prelude には `curry` と `uncurry` が用意されている。
--
-- カリー化とアンカリー化は行き来できる。両者はある意味で「同じ」であり、
-- FP の用語では _同型_ ("iso" = 同じ; "morphe" = 形、形式) と呼ぶ。
-- これは圏論から受け継いだ用語だ。

-- Exercise 2.5: `compose` を実装せよ。
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)
