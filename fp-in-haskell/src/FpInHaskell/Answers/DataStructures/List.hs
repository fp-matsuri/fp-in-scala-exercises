{-# LANGUAGE BangPatterns #-}
-- `result` の case 式は、GHC がリテラルからなる分岐を静的に「冗長」と判定して警告を出す
-- (実行される枝が1つに決まってしまうため)。この警告をファイル単位で抑制しておく。
{-# OPTIONS_GHC -Wno-overlapping-patterns #-}

module FpInHaskell.Answers.DataStructures.List (
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
    foldRightViaFoldLeft,
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
-- Haskell にはリストリテラルを直接書く糖衣構文がないため、ここでは `Cons` を直接ネストして書く。
result :: Int
result = case Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 Nil)))) of
    Cons x (Cons 2 (Cons 4 _)) -> x
    Nil -> 42
    Cons x (Cons y (Cons 3 (Cons 4 _))) -> x + y
    Cons h t -> h + sum t
    _ -> 101

-- 答え: 3。最初にマッチするのは3番目のケースで、`x` は1、`y` は2に束縛される。

append :: List a -> List a -> List a
append Nil a2 = a2
append (Cons h t) a2 = Cons h (append t a2)

-- Prelude の `foldr` と同じ引数順（関数、初期値、リストの順）に揃えてある。
-- 畳み込み対象のデータ構造を最後の引数に置くと、部分適用や `.` によるポイントフリーな関数合成が
-- しやすくなる（`sumViaFoldRight`/`productViaFoldRight` の定義を見比べてみてほしい）。
foldRight :: (a -> b -> b) -> b -> List a -> b
foldRight _ z Nil = z
foldRight f z (Cons x xs) = f x (foldRight f z xs)

sumViaFoldRight :: List Int -> Int
sumViaFoldRight = foldRight (+) 0

productViaFoldRight :: List Double -> Double
productViaFoldRight = foldRight (*) 1.0

-- Exercise 3.2: 先頭要素以外のリストを返す関数 `tail` を定義せよ。
--
-- 空リストに対しては `Nil` を返す代わりに例外を投げることにする。この判断はやや主観的だが、
-- 経験上、空リストの `tail` を取ろうとするのはバグであることが多く、黙って値を返すとバグの発見が
-- 遅れるだけになりがちだ。
tail :: List a -> List a
tail Nil = error "tail of empty list"
tail (Cons _ t) = t

-- Exercise 3.3: リストの先頭要素を別の値に置き換える関数 `setHead` を定義せよ。
setHead :: a -> List a -> List a
setHead _ Nil = error "setHead on empty list"
setHead h (Cons _ t) = Cons h t

-- Exercise 3.4: リストの先頭から `n` 個の要素を取り除く関数 `drop` を定義せよ。
--
-- Prelude の `drop` と同じ引数順（取り除く個数、リストの順）。
drop :: Int -> List a -> List a
drop n (Cons _ t) | n > 0 = drop (n - 1) t
drop _ l = l

-- Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数 `dropWhile` を定義せよ。
--
-- Prelude の `dropWhile` と同じ引数順（述語関数、リストの順）。
dropWhile :: (a -> Bool) -> List a -> List a
dropWhile f (Cons h t) | f h = dropWhile f t
dropWhile _ l = l

-- Exercise 3.6: 末尾要素以外のリストを返す関数 `init` を定義せよ。
--
-- 最後の要素にたどり着くまでリスト全体をコピーする。効率が悪いだけでなく、
-- 素直な再帰実装はリストの要素数だけスタックフレームを消費するため、
-- 大きなリストではスタックオーバーフローを起こしうる(理由がわかるだろうか?)。
init :: List a -> List a
init Nil = error "init of empty list"
init (Cons _ Nil) = Nil
init (Cons h t) = Cons h (init t)

-- Exercise 3.7: `foldRight` によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか?
--
-- 可能。Haskell は既定で遅延評価であり、上の `foldRight` の定義はサンク(未評価の計算)を
-- 積むだけで、`f` が第2引数を実際に必要とするまで再帰呼び出しは評価されない。したがって `f` が
-- 短絡可能な演算(例えば `||`)であれば、`foldRight` は実際にリストの途中で止まる。例えば
-- `foldRight (\x acc -> x == 3 || acc) False (Cons 3 undefined)` は `undefined` を評価せずに
-- `True` を返す。これは遅延評価がもたらす実利的な効果の一例だ。

-- Exercise 3.8: `foldRight` の引数の初期値に `Nil`、関数に `Cons` を与えるとどのような結果が得られるか?
-- (推測してから ghci で確認してみよう)
--
-- 元のリストがそのまま得られる。`foldRight` は直感的には、リストの `Nil` を初期値に、`Cons` を渡した
-- 関数に置き換える操作だとみなせる。初期値に `Nil` を、関数に `Cons` を渡せば入力のリストが
-- そのまま戻ってくる。
--
-- foldRight Cons Nil (Cons 1 (Cons 2 (Cons 3 Nil)))
-- = Cons 1 (foldRight Cons Nil (Cons 2 (Cons 3 Nil)))
-- = Cons 1 (Cons 2 (foldRight Cons Nil (Cons 3 Nil)))
-- = Cons 1 (Cons 2 (Cons 3 (foldRight Cons Nil Nil)))
-- = Cons 1 (Cons 2 (Cons 3 Nil))

-- Exercise 3.9: リストの要素数を数える関数 `length` を定義せよ。
length :: List a -> Int
length = foldRight (\_ acc -> acc + 1) 0

-- Exercise 3.10: リストを左端から畳み込む `foldLeft` 関数を末尾再帰関数として定義せよ。
--
-- Prelude の `foldl` と同じ引数順（関数、初期値、リストの順）。Haskell は既定で遅延評価なので、
-- 末尾再帰にしただけでは `f acc h` が評価されずサンクのまま渡り、大きなリストで積み上がって
-- スペースリークを起こす。蓄積値を `!acc` で正格に評価させて初めて安全な畳み込みになる。
-- 実務で `[a]` を畳み込むときも、素の `foldl` ではなく正格版の `Data.List.foldl'` を使うべきだ。
--
-- 遅延評価と相性がよい `foldr` も標準的に使われるので、畳み込みには両方の使いどころがある。
-- `foldr` が無限リストに対応でき短絡評価もできる点は Exercise 3.7 を参照。
foldLeft :: (b -> a -> b) -> b -> List a -> b
foldLeft _ !acc Nil = acc
foldLeft f !acc (Cons h t) = foldLeft f (f acc h) t

-- Exercise 3.11: `foldLeft` を用いて `sum`, `product`, `length` を定義せよ。
sumViaFoldLeft :: List Int -> Int
sumViaFoldLeft = foldLeft (+) 0

productViaFoldLeft :: List Double -> Double
productViaFoldLeft = foldLeft (*) 1.0

lengthViaFoldLeft :: List a -> Int
lengthViaFoldLeft = foldLeft (\acc _ -> acc + 1) 0

-- Exercise 3.12: `foldLeft` を用いてリストを逆順にする関数 `reverse` を定義せよ。
reverse :: List a -> List a
reverse = foldLeft (\acc h -> Cons h acc) Nil

-- Exercise 3.13: `foldLeft` を用いて `foldRight` を定義することは可能か? 可能であれば定義せよ。
--
-- `reverse` と `foldLeft` を使って `foldRight` を実装するのは、素朴な再帰実装が大きなリストで
-- スタックオーバーフローを起こしうる場合に、それを避けるための常套手段だ。上の `foldLeft` が
-- `!acc` で蓄積値を正格に評価するからこそ安全に機能する。この話題は第5章の遅延評価で
-- 再び取り上げる。
foldRightViaFoldLeft :: (a -> b -> b) -> b -> List a -> b
foldRightViaFoldLeft f acc l = foldLeft (\y x -> f x y) acc (reverse l)

-- Exercise 3.14: `foldRight` を用いて `append` を定義せよ。
--
-- `append` は1番目のリストの `Nil` を2番目のリストで置き換える操作であり、それはまさに `foldRight` が
-- 行っていることそのものだ。
appendViaFoldRight :: List a -> List a -> List a
appendViaFoldRight l r = foldRight Cons r l

-- Exercise 3.15: `foldRight` を用いてリストのリストを1つのリストに連結する関数 `concat` を定義せよ。
concat :: List (List a) -> List a
concat = foldRight append Nil

-- Exercise 3.16: `foldRight` を用いてリストの各要素に1を加える関数 `incrementEach` を定義せよ。
incrementEach :: List Int -> List Int
incrementEach = foldRight (\x acc -> Cons (x + 1) acc) Nil

-- Exercise 3.17: `foldRight` を用いてリストの各要素の数値を文字列に変換する関数 `doubleToString` を定義せよ。
doubleToString :: List Double -> List String
doubleToString = foldRight (\x acc -> Cons (show x) acc) Nil

-- Exercise 3.18: `doubleToString` を一般化して、リストの各要素に関数 `f` を適用する関数 `map` を定義せよ。
--
-- Prelude の `map` と同じ引数順（関数、リストの順）。
map :: (a -> b) -> List a -> List b
map f = foldRight (\h t -> Cons (f h) t) Nil

-- Exercise 3.19: リストの各要素を述語関数 `f` に従ってフィルタリングする関数 `filter` を定義せよ。
--
-- Prelude の `filter` と同じ引数順（述語関数、リストの順）。
filter :: (a -> Bool) -> List a -> List a
filter f = foldRight (\h t -> if f h then Cons h t else t) Nil

-- Exercise 3.20: リストの各要素を関数 `f` に適用して得られるリストのリストを1つのリストに連結する関数
-- `flatMap` を定義せよ。
flatMap :: (a -> List b) -> List a -> List b
flatMap f l = concat (map f l)

-- Exercise 3.21: `flatMap` を用いて `filter` を定義せよ。
filterViaFlatMap :: (a -> Bool) -> List a -> List a
filterViaFlatMap f = flatMap (\x -> if f x then Cons x Nil else Nil)

-- Exercise 3.22: リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを返す
-- 関数 `addPairwise` を定義せよ。`a`, `b` の長さが異なる場合、返すリストの長さは短いほうに一致する。
addPairwise :: List Int -> List Int -> List Int
addPairwise Nil _ = Nil
addPairwise _ Nil = Nil
addPairwise (Cons h1 t1) (Cons h2 t2) = Cons (h1 + h2) (addPairwise t1 t2)

-- Exercise 3.23: `addPairwise` を一般化して、リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素に
-- 関数 `f` を適用して得られたリストを返す関数 `zipWith` を定義せよ。
--
-- Haskell では関数に明示的な型シグネチャが必須なので、ここでは Prelude の `zipWith` と同じ形
-- （関数、2つのリストの順）で確定させている。
zipWith :: (a -> b -> c) -> List a -> List b -> List c
zipWith _ Nil _ = Nil
zipWith _ _ Nil = Nil
zipWith f (Cons h1 t1) (Cons h2 t2) = Cons (f h1 h2) (zipWith f t1 t2)

-- Exercise 3.24: リスト `sup` の中にリスト `sub` が部分列として含まれているかどうかを判定する関数
-- `hasSubsequence` を定義せよ。
-- 例えば、`Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))` は 1,2 / 2,3 / 4 を部分列として含むが、
-- 1,4 は部分列として含まない。
hasSubsequence :: (Eq a) => List a -> List a -> Bool
hasSubsequence Nil sub = isNil sub
hasSubsequence sup sub | startsWith sup sub = True
hasSubsequence (Cons _ t) sub = hasSubsequence t sub

isNil :: List a -> Bool
isNil Nil = True
isNil _ = False

startsWith :: (Eq a) => List a -> List a -> Bool
startsWith _ Nil = True
startsWith (Cons h t) (Cons h2 t2) | h == h2 = startsWith t t2
startsWith _ _ = False
