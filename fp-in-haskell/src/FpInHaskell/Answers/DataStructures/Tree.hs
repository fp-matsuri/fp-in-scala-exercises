module FpInHaskell.Answers.DataStructures.Tree (
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
depth (Leaf _) = 0
depth (Branch l r) = 1 + max (depth l) (depth r)

-- Exercise 3.27: ツリーの各リーフに関数 `f` を適用する関数 `map` を定義せよ。
map :: (a -> b) -> Tree a -> Tree b
map f (Leaf a) = Leaf (f a)
map f (Branch l r) = Branch (map f l) (map f r)

-- Exercise 3.28-1: ツリーのリーフの値を変換する関数 `f` とブランチの左右の値をまとめる関数 `g` を受け取って
-- ツリーを畳み込む関数 `fold` を定義せよ。また、`fold` を用いて `size`、`depth`、`map` を定義せよ。
--
-- リストの `foldRight` と同様、`fold` はツリーの各データ構築子に対する「ハンドラ」を受け取り、
-- それらを使って再帰的に値を積み上げる。`fold Leaf Branch t` は `t` 自身に等しく、
-- パターンマッチで書けるほとんどの再帰関数はこの `fold` を使って実装できる。
fold :: (a -> b) -> (b -> b -> b) -> Tree a -> b
fold f _ (Leaf a) = f a
fold f g (Branch l r) = g (fold f g l) (fold f g r)

sizeViaFold :: Tree a -> Int
sizeViaFold = fold (const 1) (\l r -> 1 + l + r)

depthViaFold :: Tree a -> Int
depthViaFold = fold (const 0) (\l r -> 1 + max l r)

mapViaFold :: (a -> b) -> Tree a -> Tree b
mapViaFold f = fold (Leaf . f) Branch

-- Scala 版は `Tree[Int]` にだけ生やす拡張メソッド(`extension`)として `firstPositive`/`maximum` を
-- 定義しているが、Haskell には特定の型にだけメソッドを追加する仕組みがない
-- （型クラスを使えば全称的な抽象化はできるが、`Tree Int` 専用の関数を作りたいだけならただの
-- 通常の関数で十分で、そのほうが単純だ）。ここでは素直に `Tree Int -> Int` の関数として定義する。
firstPositive :: Tree Int -> Int
firstPositive (Leaf i) = i
firstPositive (Branch l r) =
    let lpos = firstPositive l
     in if lpos > 0 then lpos else firstPositive r

-- Exercise 3.25: ツリーのリーフの最大値を計算する関数 `maximum` を定義せよ。
--
-- `size` との実装の類似性に注目してほしい。この共通パターンは後の演習で `fold` として抽象化する。
maximum :: Tree Int -> Int
maximum (Leaf n) = n
maximum (Branch l r) = max (maximum l) (maximum r)

-- Exercise 3.28-2: `fold` を用いて `maximum` を定義せよ。
maximumViaFold :: Tree Int -> Int
maximumViaFold = fold id max
