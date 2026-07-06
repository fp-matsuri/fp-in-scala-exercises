module FpInHaskell.Exercises.Laziness.LazyList (
    LazyList (..),
    foldRight,
    exists,
    find,
    toList,
    take,
    drop,
    takeWhile,
    forAll,
    headOption,
    map,
    filter,
    append,
    flatMap,
    ones,
    continually,
    from,
    fibs,
    unfold,
    fibsViaUnfold,
    fromViaUnfold,
    continuallyViaUnfold,
    onesViaUnfold,
    mapViaUnfold,
    takeViaUnfold,
    takeWhileViaUnfold,
    zipWith,
    zipAll,
    startsWith,
    tails,
    scanRight,
    hasSubsequence,
) where

import Prelude hiding (drop, filter, map, take, takeWhile, zipWith)

-- `LazyList` 型。データ構築子のフィールドは Haskell の既定である非正格評価によって
-- 自動的に評価が遅延されるため、`Cons a (LazyList a)` と素直に書くだけで無限リストを
-- 表現できる。明示的なサンクや、それを扱うための `cons` スマートコンストラクタは一切不要になる。
--
-- また、`ones`/`fibs` のように無限になりうる値を含むため、`deriving (Eq, Show)` はしない
-- (無限リストの構造的な等値比較や表示は停止しない)。テストでは必ず `take n` で有限に
-- 切り詰めてから `toList` で `[a]` に変換して比較する。
data LazyList a
    = Empty
    | Cons a (LazyList a)

-- 関数の引数は既定で非正格なので、初期値と `f` の第2引数は実際に必要とされるまで評価されない。
-- これにより、無限リストに対しても途中で畳み込みを打ち切れる。
foldRight :: (a -> b -> b) -> b -> LazyList a -> b
foldRight _ z Empty = z
foldRight f z (Cons x xs) = f x (foldRight f z xs)

-- `p a || b` の `||` は第2引数を非正格に扱うため、`p a` が `True` になった時点で `b`
-- (残りの畳み込み)は評価されず、無限リストに対しても停止する。
exists :: (a -> Bool) -> LazyList a -> Bool
exists p = foldRight (\x acc -> p x || acc) False

find :: (a -> Bool) -> LazyList a -> Maybe a
find _ Empty = Nothing
find f (Cons h t) = if f h then Just h else find f t

-- Exercise 5.1: 遅延リストをリストに変換する関数 `toList` を定義せよ。

toList :: LazyList a -> [a]
toList = undefined

-- Exercise 5.2: 遅延リストの先頭から最初の `n` 要素を返す関数 `take`、
-- 先頭から最初の `n` 要素をスキップする関数 `drop` を定義せよ。
--
-- Prelude の `take`/`drop` と同じ引数順。

take :: Int -> LazyList a -> LazyList a
take = undefined

drop :: Int -> LazyList a -> LazyList a
drop = undefined

-- Exercise 5.3: 遅延リストの先頭から条件を満たす限り続けて要素を返す関数 `takeWhile` を定義せよ。

takeWhile :: (a -> Bool) -> LazyList a -> LazyList a
takeWhile = undefined

-- Exercise 5.4: 遅延リストのすべての要素が条件を満たすかどうかを判定する関数 `forAll` を定義せよ。

forAll :: (a -> Bool) -> LazyList a -> Bool
forAll = undefined

-- Exercise 5.5: `foldRight` を用いて `takeWhile` を実装せよ。
-- (答え合わせは Answers を参照。テスト対象ではない)

-- Exercise 5.6: `foldRight` を用いて先頭要素を返す関数 `headOption` を実装せよ。
--
-- 戻り値は ch4 で自作した `Option` ではなく Prelude の `Maybe` を使う。章をまたいだ依存を
-- 持ち込まないためだ。

headOption :: LazyList a -> Maybe a
headOption = undefined

-- Exercise 5.7: `foldRight` を用いて `map`, `filter`, `append`, `flatMap` を実装せよ。
--
-- Prelude の `map` と同じ引数順。

map :: (a -> b) -> LazyList a -> LazyList b
map = undefined

filter :: (a -> Bool) -> LazyList a -> LazyList a
filter = undefined

append :: LazyList a -> LazyList a -> LazyList a
append = undefined

flatMap :: (a -> LazyList b) -> LazyList a -> LazyList b
flatMap = undefined

-- 1を無限に繰り返す遅延リスト。通常の自己参照的な定義がそのまま正しく動作し、
-- `ones` を強制評価するたびに同じ先頭サンクが使い回される。
ones :: LazyList Int
ones = Cons 1 ones

-- Exercise 5.8: 任意の値を無限に繰り返す遅延リストを生成する関数 `continually` を定義せよ。

continually :: a -> LazyList a
continually = undefined

-- Exercise 5.9: `n` から1ずつ増える無限の遅延リストを生成する関数 `from` を定義せよ。

from :: Int -> LazyList Int
from = undefined

-- Exercise 5.10: フィボナッチ数の無限の遅延リストを生成する関数 `fibs` を定義せよ。

fibs :: LazyList Int
fibs = undefined

-- Exercise 5.11: 初期状態 `state`、状態から次の要素と次の状態を返す関数 `f` を受け取って
-- 遅延リストを生成する一般的な関数 `unfold` を定義せよ。
--
-- Prelude の `Data.List.unfoldr :: (b -> Maybe (a, b)) -> b -> [a]` と同じ引数順
-- (関数、初期状態の順)。

unfold :: (s -> Maybe (a, s)) -> s -> LazyList a
unfold = undefined

-- Exercise 5.12: `unfold` を用いて `fibs`, `from`, `continually`, `ones` を実装せよ。

fibsViaUnfold :: LazyList Int
fibsViaUnfold = undefined

fromViaUnfold :: Int -> LazyList Int
fromViaUnfold = undefined

continuallyViaUnfold :: a -> LazyList a
continuallyViaUnfold = undefined

onesViaUnfold :: LazyList Int
onesViaUnfold = undefined

-- Exercise 5.13: `unfold` を用いて `map`, `take`, `takeWhile`, `zipWith`, `zipAll` を実装せよ。
-- `zipAll` は2つの遅延リストが両方とも尽きるまでそれぞれ先頭から順に取り出して対応する要素を
-- ペアにして返す。

mapViaUnfold :: (a -> b) -> LazyList a -> LazyList b
mapViaUnfold = undefined

takeViaUnfold :: Int -> LazyList a -> LazyList a
takeViaUnfold = undefined

takeWhileViaUnfold :: (a -> Bool) -> LazyList a -> LazyList a
takeWhileViaUnfold = undefined

-- Prelude の `zipWith` と同じ引数順(関数、2つのリストの順)。
zipWith :: (a -> b -> c) -> LazyList a -> LazyList b -> LazyList c
zipWith = undefined

zipAll :: LazyList a -> LazyList b -> LazyList (Maybe a, Maybe b)
zipAll = undefined

-- Exercise 5.14: 定義済みの関数を用いて遅延リストが `prefix` で始まるかどうか判定する
-- 関数 `startsWith` を定義せよ。
--
-- Prelude の `Data.List.isPrefixOf` と同じ引数順(接頭辞、対象のリストの順)。

startsWith :: (Eq a) => LazyList a -> LazyList a -> Bool
startsWith = undefined

-- Exercise 5.15: `unfold` を用いて遅延リストに `tail` を繰り返し適用した結果を返す
-- 関数 `tails` を定義せよ。
-- 例えば `tails` を `Cons 1 (Cons 2 (Cons 3 Empty))` に適用すると、
-- `[1,2,3]`, `[2,3]`, `[3]`, `[]` に対応する遅延リストの遅延リストを返す。

tails :: LazyList a -> LazyList (LazyList a)
tails = undefined

-- Exercise 5.16: `tails` を一般化して、`foldRight` の累積値を要素とする遅延リストを返す
-- 関数 `scanRight` を定義せよ。

scanRight :: (a -> b -> b) -> b -> LazyList a -> LazyList b
scanRight = undefined

-- `tails`/`startsWith` を組み合わせた、部分列判定。演習番号はないが(3.24 の List.hasSubsequence
-- に相当する)、テスト対象として実装する。

hasSubsequence :: (Eq a) => LazyList a -> LazyList a -> Bool
hasSubsequence = undefined
