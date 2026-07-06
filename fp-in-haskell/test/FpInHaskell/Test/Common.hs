module FpInHaskell.Test.Common (
    firstFibs,
    genLengthOfFibonacciSeq,
    genSmallInt,
    genSorted,
    genUnsorted,
    fromDataList,
    toDataList,
    genDataList,
    genIntDataList,
    genDoubleDataList,
    genDataListOfDataLists,
    genIntTree,
    genOption,
    genIntOption,
    genEither,
    genStringIntEither,
    fromLazyList,
) where

import Data.List (sort)
import FpInHaskell.Exercises.DataStructures.List (List (Cons, Nil))
import FpInHaskell.Exercises.DataStructures.Tree (Tree (Branch, Leaf))
import FpInHaskell.Exercises.ErrorHandling.Either (Either (Left, Right))
import FpInHaskell.Exercises.ErrorHandling.Option (Option (None, Some))
import qualified FpInHaskell.Exercises.Laziness.LazyList as LZ
import Test.QuickCheck hiding (Some)
import Prelude hiding (Either (..))

firstFibs :: [Int]
firstFibs = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765]

genLengthOfFibonacciSeq :: Gen Int
genLengthOfFibonacciSeq = choose (0, length firstFibs - 1)

genSmallInt :: Gen Int
genSmallInt = choose (0, 20)

genSorted :: Gen [Int]
genSorted = do
    n <- choose (0, 20)
    xs <- vectorOf n (choose (0, 20))
    return (sort xs)

genUnsorted :: Gen [Int]
genUnsorted = do
    n <- choose (2, 20)
    xs <- vectorOf n (choose (0, 20))
    return (zipWith (\x i -> if even i then x + 100 else x - 100) xs [0 ..])

-- DataStructures 章 (List/Tree) 向けのブリッジ関数とジェネレータ。
-- `List`/`Tree` は演習で自作する独自の代数的データ型で、ライブラリ本体には Prelude の `[a]` との
-- 相互変換手段を持たせない(演習で問われていない変換をAPIとして持ち込みたくないため)。
-- そのため、テストのオラクル(Prelude の `[a]`/`Data.List` の関数)と比較するための変換は
-- ここ(テスト専用のヘルパー)に閉じ込める。

-- | Prelude の `[a]` から `List a` を作る（テスト専用）。
fromDataList :: [a] -> List a
fromDataList = foldr Cons Nil

-- | `List a` を Prelude の `[a]` に変換する（テスト専用。オラクルとの比較に使う）。
toDataList :: List a -> [a]
toDataList Nil = []
toDataList (Cons x xs) = x : toDataList xs

genDataList :: Gen a -> Gen (List a)
genDataList genElem = do
    n <- genSmallInt
    fromDataList <$> vectorOf n genElem

genIntDataList :: Gen (List Int)
genIntDataList = genDataList arbitrary

genDoubleDataList :: Gen (List Double)
genDoubleDataList = genDataList arbitrary

genDataListOfDataLists :: Gen (List (List Int))
genDataListOfDataLists = genDataList genIntDataList

{- | ランダムな二分木を生成する。各ノードで葉になるか枝分かれするかを2:1の比率で決めており、
単純な五分五分（期待値が発散する臨界分岐過程になる）よりも生成される木を小さく保てる。
また `sized` を使うことで、QuickCheck が試行を重ねるにつれ徐々に大きな木を試すようになる
（再帰的なジェネレータでサイズ発散を防ぐ定石）。
-}
genIntTree :: Gen (Tree Int)
genIntTree = sized go
  where
    go n
        | n <= 1 = Leaf <$> arbitrary
        | otherwise =
            frequency
                [ (2, Leaf <$> arbitrary)
                , (1, Branch <$> go (n `div` 2) <*> go (n `div` 2))
                ]

-- ErrorHandling 章 (Option/Either) 向けのジェネレータ。
-- `None`/`Some` と `Left`/`Right` は五分五分の union にする(scala版 OptionSuite/EitherSuite の
-- ジェネレータと同じ方針)。
genOption :: Gen a -> Gen (Option a)
genOption genA = oneof [pure None, Some <$> genA]

genIntOption :: Gen (Option Int)
genIntOption = genOption arbitrary

genEither :: Gen e -> Gen a -> Gen (Either e a)
genEither genE genA = oneof [Left <$> genE, Right <$> genA]

genStringIntEither :: Gen (Either String Int)
genStringIntEither = genEither arbitrary arbitrary

-- Laziness 章 (LazyList) 向けのブリッジ関数。
-- `LazyList` の構築子は `List` と同じ名前(`Cons`)を使うため、ここでは `LZ.` で修飾 import している。
--
-- `LazyList` は `ones`/`fibs` のように無限になりうるため、`Show`/`Eq` を導出していない
-- (導出すると無限リストの比較・表示が停止しなくなる)。QuickCheck の `forAll` は生成する値に
-- `Show` を要求するため、`LazyList` を直接 `forAll` に渡すことができない。そのため、
-- テストでは常に `Show` を持つ Prelude の `[a]` を `forAll` で生成し、この `fromLazyList` で
-- `LazyList a` に変換してから演習の関数に渡す(逆方向の変換である `toList` はそれ自体が
-- 演習 5.1 なので、ライブラリ側で提供される)。
fromLazyList :: [a] -> LZ.LazyList a
fromLazyList = foldr LZ.Cons LZ.Empty
