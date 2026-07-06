module FpInHaskell.Exercises.DataStructures.Tree (
    Tree (..),
    size,
    depth,
    map,
    fold,
    sizeViaFold,
    depthViaFold,
    mapViaFold,
    firstPositive,
    maximum,
    maximumViaFold,
) where

import Prelude hiding (map, maximum)

-- `Tree` 型。List.hs と同様、要素の型 `a` でパラメータ化された二分木。
-- Prelude の `map`/`maximum` と名前が衝突するため、ファイル冒頭でそれらを隠している。
data Tree a
    = Leaf a
    | Branch (Tree a) (Tree a)
    deriving (Show, Eq)

-- Scala 版はインスタンスメソッド `Tree[A].size` とコンパニオンの関数 `Tree.size(t)` の
-- 2通りを用意しているが、これはメソッド呼び出しとトップレベル関数呼び出しという Scala 特有の
-- 使い分けを示すためのものだ。Haskell にはメソッド/関数の区別自体がないため、1つの定義で足りる。
size :: Tree a -> Int
size (Leaf _) = 1
size (Branch l r) = 1 + size l + size r

-- Exercise 3.26: ツリーの深さを計算する関数 `depth` を定義せよ。深さは、ルートから最も遠いリーフまでの
-- パスの長さである。

depth :: Tree a -> Int
depth = undefined

-- Exercise 3.27: ツリーの各リーフに関数 `f` を適用する関数 `map` を定義せよ。

map :: (a -> b) -> Tree a -> Tree b
map = undefined

-- Exercise 3.28-1: ツリーのリーフの値を変換する関数 `f` とブランチの左右の値をまとめる関数 `g` を受け取って
-- ツリーを畳み込む関数 `fold` を定義せよ。また、`fold` を用いて `size`、`depth`、`map` を定義せよ。

fold :: (a -> b) -> (b -> b -> b) -> Tree a -> b
fold = undefined

sizeViaFold :: Tree a -> Int
sizeViaFold = undefined

depthViaFold :: Tree a -> Int
depthViaFold = undefined

mapViaFold :: (a -> b) -> Tree a -> Tree b
mapViaFold = undefined

-- Scala 版では Exercise 3.25 の `maximum` の前に、同じ拡張メソッドの仕組みを示す例として
-- `firstPositive` が(演習番号なしで)スタブのまま置かれている。ここでも同様に扱う。

firstPositive :: Tree Int -> Int
firstPositive = undefined

-- Exercise 3.25: ツリーのリーフの最大値を計算する関数 `maximum` を定義せよ。

maximum :: Tree Int -> Int
maximum = undefined

-- Exercise 3.28-2: `fold` を用いて `maximum` を定義せよ。

maximumViaFold :: Tree Int -> Int
maximumViaFold = undefined
