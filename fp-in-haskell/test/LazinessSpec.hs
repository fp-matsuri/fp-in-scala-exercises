module LazinessSpec (
    props,
) where

import Data.List (isInfixOf, isPrefixOf, tails)
import FpInHaskell.Exercises.Laziness.LazyList (LazyList (Cons, Empty))
import qualified FpInHaskell.Exercises.Laziness.LazyList as LZ
import FpInHaskell.Test.Common
import Test.QuickCheck

-- ch3/ch4 の Spec と同じ理由で、演習対象のモジュールだけを修飾 import している(`LZ.`)。
--
-- `LazyList` には `Show`/`Eq` を導出していない(無限リストになりうるため)。QuickCheck の
-- `forAll` は生成する値に `Show` を要求するので、`LazyList` を直接 `forAll` に渡すことはできない。
-- そのため、ここでは常に `Show` を持つ Prelude の `[Int]` を `forAll` で生成し、プロパティの中で
-- `fromLazyList` を使って `LazyList Int` に変換してから演習の関数に渡す。
--
-- また、原典の LazyListSuite 自身が map/filter/append/flatMap/zipWith/zipAll/tails/
-- scanRight/hasSubsequence とその ViaUnfold 系のテストをコメントアウトしている
-- (おそらく自作の PBT エンジンでの記述が難しかったため)。ここでは QuickCheck を使い、
-- それらも含めて全演習をテストする。

genIntListPlain :: Gen [Int]
genIntListPlain = listOf arbitrary

prop_toList :: Property
prop_toList = forAll genIntListPlain $ \xs ->
    LZ.toList (fromLazyList xs) === xs

prop_take :: Property
prop_take = forAll ((,) <$> choose (0, 10) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.take n (fromLazyList xs)) === take n xs

prop_drop :: Property
prop_drop = forAll ((,) <$> choose (0, 10) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.drop n (fromLazyList xs)) === drop n xs

prop_takeWhile :: Property
prop_takeWhile = forAll ((,) <$> choose (-10, 10) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.takeWhile (/= n) (fromLazyList xs)) === takeWhile (/= n) xs

prop_forAll :: Property
prop_forAll = forAll ((,) <$> choose (-10, 10) <*> genIntListPlain) $ \(n, xs) ->
    LZ.forAll (/= n) (fromLazyList xs) === notElem n xs

-- `ones`(無限に1を繰り返す、given の定数)に対して `forAll (/= 1)` を適用すると、
-- 最初の要素で条件を満たさないと判明するため、`&&` の遅延評価により即座に `False` が
-- 返る(全要素を走査しようとしたら無限ループになり、テストはタイムアウトする)。
prop_forAll_infinite :: Property
prop_forAll_infinite = once (LZ.forAll (/= 1) LZ.ones === False)

-- 同様に `headOption` も先頭だけを見て停止する。
prop_headOption_infinite :: Property
prop_headOption_infinite = once (LZ.headOption LZ.ones === Just 1)

prop_headOption :: Property
prop_headOption = forAll genIntListPlain $ \ys ->
    let xs = fromLazyList ys
     in case xs of
            Empty -> LZ.headOption xs === Nothing
            Cons h _ -> LZ.headOption xs === Just h

prop_map :: Property
prop_map = forAll ((,) <$> (arbitrary :: Gen Int) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.map (+ n) (fromLazyList xs)) === map (+ n) xs

prop_filter :: Property
prop_filter = forAll ((,) <$> choose (-10, 10) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.filter (/= n) (fromLazyList xs)) === filter (/= n) xs

prop_append :: Property
prop_append = forAll ((,) <$> genIntListPlain <*> genIntListPlain) $ \(xs, ys) ->
    LZ.toList (LZ.append (fromLazyList xs) (fromLazyList ys)) === xs ++ ys

prop_flatMap :: Property
prop_flatMap = forAll ((,) <$> (arbitrary :: Gen Int) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.flatMap (\a -> fromLazyList [a, a + n]) (fromLazyList xs))
        === concatMap (\a -> [a, a + n]) xs

prop_continually :: Property
prop_continually = forAll ((,) <$> choose (0, 100) <*> (arbitrary :: Gen Int)) $ \(n, a) ->
    LZ.toList (LZ.take n (LZ.continually a)) === replicate n a

prop_from :: Property
prop_from = forAll ((,) <$> choose (0, 100) <*> (arbitrary :: Gen Int)) $ \(n, a) ->
    LZ.toList (LZ.take n (LZ.from a)) === take n [a ..]

prop_fibs :: Property
prop_fibs = forAll genLengthOfFibonacciSeq $ \n ->
    LZ.toList (LZ.take n LZ.fibs) === take n firstFibs

prop_unfold :: Property
prop_unfold = forAll (choose (0, 100) :: Gen Int) $ \n ->
    LZ.toList (LZ.unfold (\m -> if m > n then Nothing else Just (m, m + 1)) 1) === [1 .. n]

prop_fibsViaUnfold :: Property
prop_fibsViaUnfold = forAll genLengthOfFibonacciSeq $ \n ->
    LZ.toList (LZ.take n LZ.fibsViaUnfold) === take n firstFibs

prop_fromViaUnfold :: Property
prop_fromViaUnfold = forAll ((,) <$> choose (0, 100) <*> (arbitrary :: Gen Int)) $ \(n, a) ->
    LZ.toList (LZ.take n (LZ.fromViaUnfold a)) === take n [a ..]

prop_continuallyViaUnfold :: Property
prop_continuallyViaUnfold = forAll ((,) <$> choose (0, 100) <*> (arbitrary :: Gen Int)) $ \(n, a) ->
    LZ.toList (LZ.take n (LZ.continuallyViaUnfold a)) === replicate n a

prop_onesViaUnfold :: Property
prop_onesViaUnfold = forAll (choose (0, 100) :: Gen Int) $ \n ->
    LZ.toList (LZ.take n LZ.onesViaUnfold) === replicate n 1

prop_mapViaUnfold :: Property
prop_mapViaUnfold = forAll ((,) <$> (arbitrary :: Gen Int) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.mapViaUnfold (+ n) (fromLazyList xs)) === map (+ n) xs

prop_takeViaUnfold :: Property
prop_takeViaUnfold = forAll ((,) <$> choose (0, 10) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.takeViaUnfold n (fromLazyList xs)) === take n xs

prop_takeWhileViaUnfold :: Property
prop_takeWhileViaUnfold = forAll ((,) <$> choose (-10, 10) <*> genIntListPlain) $ \(n, xs) ->
    LZ.toList (LZ.takeWhileViaUnfold (/= n) (fromLazyList xs)) === takeWhile (/= n) xs

prop_zipWith :: Property
prop_zipWith = forAll ((,) <$> genIntListPlain <*> genIntListPlain) $ \(xs, ys) ->
    LZ.toList (LZ.zipWith (+) (fromLazyList xs) (fromLazyList ys)) === zipWith (+) xs ys

prop_zipAll :: Property
prop_zipAll = forAll ((,) <$> genIntListPlain <*> genIntListPlain) $ \(xs, ys) ->
    LZ.toList (LZ.zipAll (fromLazyList xs) (fromLazyList ys)) === zipAllRef xs ys
  where
    zipAllRef (a : as) (b : bs) = (Just a, Just b) : zipAllRef as bs
    zipAllRef (a : as) [] = (Just a, Nothing) : zipAllRef as []
    zipAllRef [] (b : bs) = (Nothing, Just b) : zipAllRef [] bs
    zipAllRef [] [] = []

prop_startsWith :: Property
prop_startsWith = forAll ((,) <$> genIntListPlain <*> genIntListPlain) $ \(xs, prefix) ->
    LZ.startsWith (fromLazyList prefix) (fromLazyList xs) === (prefix `isPrefixOf` xs)

prop_tails :: Property
prop_tails = forAll genIntListPlain $ \xs ->
    map LZ.toList (LZ.toList (LZ.tails (fromLazyList xs))) === tails xs

prop_scanRight :: Property
prop_scanRight = forAll genIntListPlain $ \xs ->
    LZ.toList (LZ.scanRight (+) 0 (fromLazyList xs)) === scanr (+) 0 xs

prop_hasSubsequence :: Property
prop_hasSubsequence = forAll ((,) <$> genIntListPlain <*> genIntListPlain) $ \(xs, sub) ->
    LZ.hasSubsequence (fromLazyList xs) (fromLazyList sub) === (sub `isInfixOf` xs)

props :: [(String, Property)]
props =
    [ ("LazyList.toList", prop_toList)
    , ("LazyList.take", prop_take)
    , ("LazyList.drop", prop_drop)
    , ("LazyList.takeWhile", prop_takeWhile)
    , ("LazyList.forAll", prop_forAll)
    , ("LazyList.forAll (infinite short-circuit)", prop_forAll_infinite)
    , ("LazyList.headOption (infinite)", prop_headOption_infinite)
    , ("LazyList.headOption", prop_headOption)
    , ("LazyList.map", prop_map)
    , ("LazyList.filter", prop_filter)
    , ("LazyList.append", prop_append)
    , ("LazyList.flatMap", prop_flatMap)
    , ("LazyList.continually", prop_continually)
    , ("LazyList.from", prop_from)
    , ("LazyList.fibs", prop_fibs)
    , ("LazyList.unfold", prop_unfold)
    , ("LazyList.fibsViaUnfold", prop_fibsViaUnfold)
    , ("LazyList.fromViaUnfold", prop_fromViaUnfold)
    , ("LazyList.continuallyViaUnfold", prop_continuallyViaUnfold)
    , ("LazyList.onesViaUnfold", prop_onesViaUnfold)
    , ("LazyList.mapViaUnfold", prop_mapViaUnfold)
    , ("LazyList.takeViaUnfold", prop_takeViaUnfold)
    , ("LazyList.takeWhileViaUnfold", prop_takeWhileViaUnfold)
    , ("LazyList.zipWith", prop_zipWith)
    , ("LazyList.zipAll", prop_zipAll)
    , ("LazyList.startsWith", prop_startsWith)
    , ("LazyList.tails", prop_tails)
    , ("LazyList.scanRight", prop_scanRight)
    , ("LazyList.hasSubsequence", prop_hasSubsequence)
    ]
