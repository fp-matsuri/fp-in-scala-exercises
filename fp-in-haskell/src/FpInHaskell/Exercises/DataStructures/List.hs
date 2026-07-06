-- `result` の case 式は、GHC がリテラルからなる分岐を静的に「冗長」と判定して警告を出す
-- (実行される枝が1つに決まってしまうため)。Scala 版もここで `@annotation.nowarn` を使って
-- 同種の警告を抑制しているので、GHC 側もファイル単位でこの警告を抑制しておく。
{-# OPTIONS_GHC -Wno-overlapping-patterns #-}

module FpInHaskell.Exercises.DataStructures.List (
    List (..),
    sum,
    product,
    result,
    append,
    foldRight,
    sumViaFoldRight,
    productViaFoldRight,
    tail,
    setHead,
    drop,
    dropWhile,
    init,
    length,
    foldLeft,
    sumViaFoldLeft,
    productViaFoldLeft,
    lengthViaFoldLeft,
    reverse,
    appendViaFoldRight,
    concat,
    incrementEach,
    doubleToString,
    map,
    filter,
    flatMap,
    filterViaFlatMap,
    addPairwise,
    zipWith,
    hasSubsequence,
) where

import Prelude hiding (
    concat,
    drop,
    dropWhile,
    filter,
    init,
    length,
    map,
    product,
    reverse,
    sum,
    tail,
    zipWith,
 )

-- `List` 型。要素の型 `a` でパラメータ化されたリスト。
-- Prelude には同名の `[a]` やこのファイルで再定義する `sum`/`map`/`filter` などの関数がすでにあるため、
-- ファイル冒頭の `import Prelude hiding (...)` でそれらを読み込み対象から外し、
-- ここでは代数的データ型として自前の `List` を一から定義し、その操作を実装する。
data List a
    = -- | 空リストを表すデータ構築子。
      Nil
    | {- | 非空リストを表すデータ構築子。2番目のフィールドはもう1つの `List a` であり、
      `Nil` か別の `Cons` になりうる。
      -}
      Cons a (List a)
    deriving (Show, Eq)

-- パターンマッチングを用いて整数のリストの合計を計算する関数
sum :: List Int -> Int
sum Nil = 0 -- 空リストの合計は0。
sum (Cons x xs) = x + sum xs -- 先頭が x のリストの合計は、x と残りのリストの合計の和。

product :: List Double -> Double
product Nil = 1.0
product (Cons 0.0 _) = 0.0
product (Cons x xs) = x * product xs

-- Exercise 3.1: 以下の式 `result` の評価結果は何になるか?(推測してから ghci で確認してみよう)
--
-- Scala 版は可変長引数の `List(1, 2, 3, 4, 5)` でリストを作れるが、
-- Haskell にはその糖衣構文がないため、ここでは `Cons` を直接ネストして書く。
result :: Int
result = case Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 Nil)))) of
    Cons x (Cons 2 (Cons 4 _)) -> x
    Nil -> 42
    Cons x (Cons y (Cons 3 (Cons 4 _))) -> x + y
    Cons h t -> h + sum t
    _ -> 101

append :: List a -> List a -> List a
append Nil a2 = a2
append (Cons h t) a2 = Cons h (append t a2)

-- Prelude の `foldr` と同じ引数順（関数、初期値、リストの順）に揃えてある。
-- Scala 版は `foldRight(as, acc, f)` のようにリストが先頭の引数だが、Haskell では畳み込み対象の
-- データ構造を最後の引数に置くのが自然で、部分適用や `.` によるポイントフリーな関数合成がしやすくなる
-- （`sumViaFoldRight`/`productViaFoldRight` の定義を見比べてみてほしい）。
foldRight :: (a -> b -> b) -> b -> List a -> b
foldRight _ z Nil = z
foldRight f z (Cons x xs) = f x (foldRight f z xs)

sumViaFoldRight :: List Int -> Int
sumViaFoldRight = foldRight (+) 0

productViaFoldRight :: List Double -> Double
productViaFoldRight = foldRight (*) 1.0

-- Exercise 3.2: 先頭要素以外のリストを返す関数 `tail` を定義せよ。

tail :: List a -> List a
tail = undefined

-- Exercise 3.3: リストの先頭要素を別の値に置き換える関数 `setHead` を定義せよ。

setHead :: a -> List a -> List a
setHead = undefined

-- Exercise 3.4: リストの先頭から `n` 個の要素を取り除く関数 `drop` を定義せよ。
--
-- Prelude の `drop` と同じ引数順（取り除く個数、リストの順）。

drop :: Int -> List a -> List a
drop = undefined

-- Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数 `dropWhile` を定義せよ。
--
-- Prelude の `dropWhile` と同じ引数順（述語関数、リストの順）。

dropWhile :: (a -> Bool) -> List a -> List a
dropWhile = undefined

-- Exercise 3.6: 末尾要素以外のリストを返す関数 `init` を定義せよ。

init :: List a -> List a
init = undefined

-- Exercise 3.7: `foldRight` によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか?
--
-- (Haskell は非正格評価なので、Scala版の解答と結論が変わる。答え合わせは Answers を参照)

-- Exercise 3.8: `foldRight` の引数の初期値に `Nil`、関数に `Cons` を与えるとどのような結果が得られるか?
-- (推測してから ghci で確認してみよう)

-- Exercise 3.9: リストの要素数を数える関数 `length` を定義せよ。

length :: List a -> Int
length = undefined

-- Exercise 3.10: リストを左端から畳み込む `foldLeft` 関数を末尾再帰関数として定義せよ。
--
-- Prelude の `foldl` と同じ引数順（関数、初期値、リストの順）。

foldLeft :: (b -> a -> b) -> b -> List a -> b
foldLeft = undefined

-- Exercise 3.11: `foldLeft` を用いて `sum`, `product`, `length` を定義せよ。

sumViaFoldLeft :: List Int -> Int
sumViaFoldLeft = undefined

productViaFoldLeft :: List Double -> Double
productViaFoldLeft = undefined

lengthViaFoldLeft :: List a -> Int
lengthViaFoldLeft = undefined

-- Exercise 3.12: `foldLeft` を用いてリストを逆順にする関数 `reverse` を定義せよ。

reverse :: List a -> List a
reverse = undefined

-- Exercise 3.13: `foldLeft` を用いて `foldRight` を定義することは可能か? 可能であれば定義せよ。
-- (答え合わせは Answers を参照。テスト対象ではない)

-- Exercise 3.14: `foldRight` を用いて `append` を定義せよ。

appendViaFoldRight :: List a -> List a -> List a
appendViaFoldRight = undefined

-- Exercise 3.15: `foldRight` を用いてリストのリストを1つのリストに連結する関数 `concat` を定義せよ。

concat :: List (List a) -> List a
concat = undefined

-- Exercise 3.16: `foldRight` を用いてリストの各要素に1を加える関数 `incrementEach` を定義せよ。

incrementEach :: List Int -> List Int
incrementEach = undefined

-- Exercise 3.17: `foldRight` を用いてリストの各要素の数値を文字列に変換する関数 `doubleToString` を定義せよ。

doubleToString :: List Double -> List String
doubleToString = undefined

-- Exercise 3.18: `doubleToString` を一般化して、リストの各要素に関数 `f` を適用する関数 `map` を定義せよ。
--
-- Prelude の `map` と同じ引数順（関数、リストの順）。

map :: (a -> b) -> List a -> List b
map = undefined

-- Exercise 3.19: リストの各要素を述語関数 `f` に従ってフィルタリングする関数 `filter` を定義せよ。
--
-- Prelude の `filter` と同じ引数順（述語関数、リストの順）。

filter :: (a -> Bool) -> List a -> List a
filter = undefined

-- Exercise 3.20: リストの各要素を関数 `f` に適用して得られるリストのリストを1つのリストに連結する関数
-- `flatMap` を定義せよ。

flatMap :: (a -> List b) -> List a -> List b
flatMap = undefined

-- Exercise 3.21: `flatMap` を用いて `filter` を定義せよ。

filterViaFlatMap :: (a -> Bool) -> List a -> List a
filterViaFlatMap = undefined

-- Exercise 3.22: リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを返す
-- 関数 `addPairwise` を定義せよ。`a`, `b` の長さが異なる場合、返すリストの長さは短いほうに一致する。

addPairwise :: List Int -> List Int -> List Int
addPairwise = undefined

-- Exercise 3.23: `addPairwise` を一般化して、リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素に
-- 関数 `f` を適用して得られたリストを返す関数 `zipWith` を定義せよ。
--
-- 原典 Scala 版ではシグネチャ自体が演習の一部で、学習者が型を決めることになっているが、
-- Haskell では関数に明示的な型シグネチャが必須なので、ここでは Prelude の `zipWith` と同じ形
-- （関数、2つのリストの順）で確定させている。

zipWith :: (a -> b -> c) -> List a -> List b -> List c
zipWith = undefined

-- Exercise 3.24: リスト `sup` の中にリスト `sub` が部分列として含まれているかどうかを判定する関数
-- `hasSubsequence` を定義せよ。
-- 例えば、`Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))` は 1,2 / 2,3 / 4 を部分列として含むが、
-- 1,4 は部分列として含まない。

hasSubsequence :: (Eq a) => List a -> List a -> Bool
hasSubsequence = undefined
