{-# LANGUAGE ScopedTypeVariables #-}

module FpInHaskell.Exercises.ErrorHandling.Option (
    Option (..),
    map,
    getOrElse,
    flatMap,
    orElse,
    filter,
    failingFn,
    failingFn2,
    mean,
    variance,
    map2,
    sequence,
    traverse,
) where

import Control.Exception (SomeException, catch, evaluate)
import Prelude hiding (filter, map, sequence, traverse)

-- `Option` 型。Prelude には同種の `Maybe`(`Just`/`Nothing`)があるが、
-- この章の目的は map/flatMap/traverse などを一から自作することなので、既存の `Maybe` を
-- 再利用せず、独自の `Option` を定義する(Prelude の `map`/`filter`/`sequence`/`traverse` は
-- 同名で再定義するため hide している)。
data Option a
    = Some a
    | None
    deriving (Show, Eq)

-- Exercise 4.1: 関数 `map`、`getOrElse`、`flatMap`、`orElse`、`filter` を実装せよ。
-- `getOrElse` は `Some` ならその中身の値を返し、`None` なら引数のデフォルト値を返す。
-- `orElse` は `Some` ならそのまま返し、`None` なら引数の Option 値を返す。
--
-- Prelude の `map` と同じ引数順(関数、Option の順)。

map :: (a -> b) -> Option a -> Option b
map = undefined

-- Prelude の `Data.Maybe.fromMaybe` と同じ引数順(デフォルト値、Option の順)。

getOrElse :: a -> Option a -> a
getOrElse = undefined

-- Prelude の `traverse`/`>>=` と同じく、関数を先、Option を最後に置く。

flatMap :: (a -> Option b) -> Option a -> Option b
flatMap = undefined

-- 第1引数がフォールバック、第2引数が本体の Option。

orElse :: Option a -> Option a -> Option a
orElse = undefined

filter :: (a -> Bool) -> Option a -> Option a
filter = undefined

-- 純粋な関数の中で `error`(回復不能な実行時エラーを表す機構)を安全に捕捉する手段はない。
-- 捕捉するには `IO` の中で `evaluate`/`catch` を使う必要があり、そのぶん戻り値の型も
-- `IO Int` にせざるを得ない。これは、この章が教える「失敗は Option/Either で表現し、
-- 例外機構には頼らない」という教訓を、型システムがさらに徹底して強制している例だと言える。
failingFn :: Int -> IO Int
failingFn _i =
    let y = error "fail!" :: Int
     in evaluate (42 + 5 + y) `catch` \(_ :: SomeException) -> return 43

failingFn2 :: Int -> IO Int
failingFn2 _i =
    evaluate (42 + 5 + (error "fail!" :: Int)) `catch` \(_ :: SomeException) -> return 43

-- 浮動小数点数のリストの平均を計算する。空リストなら `None`。
mean :: [Double] -> Option Double
mean [] = None
mean xs = Some (sum xs / fromIntegral (length xs))

-- Exercise 4.2: 分散(平均からの偏差の2乗の平均)を計算する関数 `variance` を定義せよ。

variance :: [Double] -> Option Double
variance = undefined

-- Exercise 4.3: 2つの Option 値がともに `Some` なら、2つの値に関数 `f` を適用する関数 `map2` を定義せよ。
-- どちらかが `None` なら結果も `None` になる。

map2 :: (a -> b -> c) -> Option a -> Option b -> Option c
map2 = undefined

-- Exercise 4.4: Option のリストをリストの Option に変換する関数 `sequence` を定義せよ。

sequence :: [Option a] -> Option [a]
sequence = undefined

-- Exercise 4.5: リストの要素に関数 `f` を適用した結果をリストの Option に変換する関数 `traverse` を定義せよ。
--
-- Prelude の `traverse` と同じ引数順(関数、リストの順)。

traverse :: (a -> Option b) -> [a] -> Option [b]
traverse = undefined
