{-# LANGUAGE ScopedTypeVariables #-}

module DataStructuresSpec (
    props,
) where

import Control.Exception (SomeException, evaluate, try)
import Data.List (find, isInfixOf)
import Data.Maybe (fromMaybe)
import FpInHaskell.Exercises.DataStructures.List (List (Cons, Nil))
import qualified FpInHaskell.Exercises.DataStructures.List as List
import FpInHaskell.Exercises.DataStructures.Tree (Tree (Branch, Leaf))
import qualified FpInHaskell.Exercises.DataStructures.Tree as Tree
import FpInHaskell.Test.Common
import Test.QuickCheck

-- 演習対象のモジュール(`FpInHaskell.Exercises.DataStructures.*`)はここでは Prelude と同じ名前の
-- 関数(`tail`/`map`/`filter`/`length`/...)を大量にエクスポートしている。Spec ファイルでそれらを
-- 使いつつ、比較先のオラクルとして Prelude 自身の同名関数も使いたいので、演習対象のモジュールだけを
-- 修飾 import する(`List.`/`Tree.` 接頭辞をつける)。こうすれば Prelude 側は
-- `import Prelude hiding (...)` なしで素のまま使え、両者を同じファイル内で衝突なく使い分けられる。

shouldThrow :: forall a. a -> Property
shouldThrow x = ioProperty $ do
    result <- try (evaluate x) :: IO (Either SomeException a)
    return (either (const True) (const False) result)

prop_tail :: Property
prop_tail = forAll genIntDataList $ \l -> case l of
    Nil -> shouldThrow (List.tail Nil)
    Cons _ xs -> List.tail l === xs

prop_setHead :: Property
prop_setHead = forAll genIntDataList $ \l -> case l of
    Nil -> shouldThrow (List.setHead 0 Nil)
    Cons _ xs -> List.setHead 0 l === Cons 0 xs

prop_drop :: Property
prop_drop = forAll ((,) <$> genIntDataList <*> choose (-10, 10)) $ \(l, n) ->
    toDataList (List.drop n l) === drop n (toDataList l)

prop_dropWhile :: Property
prop_dropWhile = forAll ((,) <$> genIntDataList <*> choose (-10, 10)) $ \(l, n) ->
    toDataList (List.dropWhile (<= n) l) === dropWhile (<= n) (toDataList l)

prop_init :: Property
prop_init = forAll genIntDataList $ \l -> case l of
    Nil -> shouldThrow (List.init Nil)
    _ -> toDataList (List.init l) === init (toDataList l)

prop_length :: Property
prop_length = forAll genIntDataList $ \l -> List.length l === length (toDataList l)

prop_foldLeft :: Property
prop_foldLeft = forAll genIntDataList $ \l ->
    List.foldLeft (\acc x -> acc ++ show x) "" l === foldl (\acc x -> acc ++ show x) "" (toDataList l)

prop_sumViaFoldLeft :: Property
prop_sumViaFoldLeft = forAll genIntDataList $ \l -> List.sumViaFoldLeft l === sum (toDataList l)

prop_productViaFoldLeft :: Property
prop_productViaFoldLeft = forAll genDoubleDataList $ \l -> List.productViaFoldLeft l === product (toDataList l)

prop_lengthViaFoldLeft :: Property
prop_lengthViaFoldLeft = forAll genIntDataList $ \l -> List.lengthViaFoldLeft l === length (toDataList l)

prop_reverse :: Property
prop_reverse = forAll genIntDataList $ \l -> toDataList (List.reverse l) === reverse (toDataList l)

prop_appendViaFoldRight :: Property
prop_appendViaFoldRight = forAll ((,) <$> genIntDataList <*> genIntDataList) $ \(l1, l2) ->
    toDataList (List.appendViaFoldRight l1 l2) === toDataList l1 ++ toDataList l2

prop_concat :: Property
prop_concat = forAll genDataListOfDataLists $ \ll ->
    toDataList (List.concat ll) === concatMap toDataList (toDataList ll)

prop_incrementEach :: Property
prop_incrementEach = forAll genIntDataList $ \l ->
    toDataList (List.incrementEach l) === map (+ 1) (toDataList l)

prop_doubleToString :: Property
prop_doubleToString = forAll genDoubleDataList $ \l ->
    toDataList (List.doubleToString l) === map show (toDataList l)

prop_map :: Property
prop_map = forAll genIntDataList $ \l ->
    toDataList (List.map (* 2) l) === map (* 2) (toDataList l)

prop_filter :: Property
prop_filter = forAll genIntDataList $ \l ->
    toDataList (List.filter even l) === filter even (toDataList l)

prop_flatMap :: Property
prop_flatMap = forAll genIntDataList $ \l ->
    toDataList (List.flatMap (\a -> Cons a (Cons a Nil)) l) === concatMap (\a -> [a, a]) (toDataList l)

prop_filterViaFlatMap :: Property
prop_filterViaFlatMap = forAll genIntDataList $ \l ->
    toDataList (List.filterViaFlatMap even l) === filter even (toDataList l)

prop_addPairwise :: Property
prop_addPairwise = forAll ((,) <$> genIntDataList <*> genIntDataList) $ \(l1, l2) ->
    toDataList (List.addPairwise l1 l2) === zipWith (+) (toDataList l1) (toDataList l2)

-- `zipWith` はシグネチャを最初から確定させているため、そのままテストできる。
prop_zipWith :: Property
prop_zipWith = forAll ((,) <$> genIntDataList <*> genIntDataList) $ \(l1, l2) ->
    toDataList (List.zipWith (*) l1 l2) === zipWith (*) (toDataList l1) (toDataList l2)

prop_hasSubsequence_structured :: Property
prop_hasSubsequence_structured = forAll ((,) <$> genIntDataList <*> choose (-10, 10)) $ \(l, n) ->
    List.hasSubsequence l Nil
        .&&. List.hasSubsequence l l
        .&&. List.hasSubsequence l (safeInit l)
        .&&. List.hasSubsequence l (safeTail l)
        .&&. List.hasSubsequence l (List.drop n l)
  where
    safeInit Nil = Nil
    safeInit l = List.init l
    safeTail Nil = Nil
    safeTail l = List.tail l

prop_hasSubsequence_random :: Property
prop_hasSubsequence_random = forAll ((,) <$> genIntDataList <*> genIntDataList) $ \(l1, l2) ->
    List.hasSubsequence l1 l2 === (toDataList l2 `isInfixOf` toDataList l1)

-- ツリーの各リーフの値を左から右の順に並べたリスト。テストのオラクル計算専用のヘルパー。
leaves :: Tree a -> [a]
leaves (Leaf a) = [a]
leaves (Branch l r) = leaves l ++ leaves r

-- `Tree.size`/`Tree.depth` の独立した参照実装。演習対象の関数を演習対象の関数自身で検算する
-- （部分木に対して被テスト関数を再帰的に呼ぶ）のではなく、ここで一から定義した別実装と比較することで、
-- 「常に自分自身と一致してしまう」ような無意味な検証を避ける。
refSize :: Tree a -> Int
refSize (Leaf _) = 1
refSize (Branch l r) = 1 + refSize l + refSize r

refDepth :: Tree a -> Int
refDepth (Leaf _) = 0
refDepth (Branch l r) = 1 + max (refDepth l) (refDepth r)

prop_Tree_size :: Property
prop_Tree_size = forAll genIntTree $ \t -> Tree.size t === refSize t

prop_Tree_depth :: Property
prop_Tree_depth = forAll genIntTree $ \t -> Tree.depth t === refDepth t

prop_Tree_map :: Property
prop_Tree_map = forAll genIntTree $ \t -> leaves (Tree.map show t) === map show (leaves t)

prop_Tree_fold :: Property
prop_Tree_fold = forAll genIntTree $ \t -> Tree.fold show (++) t === concatMap show (leaves t)

prop_Tree_sizeViaFold :: Property
prop_Tree_sizeViaFold = forAll genIntTree $ \t -> Tree.sizeViaFold t === refSize t

prop_Tree_depthViaFold :: Property
prop_Tree_depthViaFold = forAll genIntTree $ \t -> Tree.depthViaFold t === refDepth t

prop_Tree_mapViaFold :: Property
prop_Tree_mapViaFold = forAll genIntTree $ \t -> leaves (Tree.mapViaFold show t) === map show (leaves t)

prop_Tree_firstPositive :: Property
prop_Tree_firstPositive = forAll genIntTree $ \t ->
    Tree.firstPositive t === fromMaybe (last (leaves t)) (find (> 0) (leaves t))

prop_Tree_maximum :: Property
prop_Tree_maximum = forAll genIntTree $ \t -> Tree.maximum t === maximum (leaves t)

prop_Tree_maximumViaFold :: Property
prop_Tree_maximumViaFold = forAll genIntTree $ \t -> Tree.maximumViaFold t === maximum (leaves t)

props :: [(String, Property)]
props =
    [ ("List.tail", prop_tail)
    , ("List.setHead", prop_setHead)
    , ("List.drop", prop_drop)
    , ("List.dropWhile", prop_dropWhile)
    , ("List.init", prop_init)
    , ("List.length", prop_length)
    , ("List.foldLeft", prop_foldLeft)
    , ("List.sumViaFoldLeft", prop_sumViaFoldLeft)
    , ("List.productViaFoldLeft", prop_productViaFoldLeft)
    , ("List.lengthViaFoldLeft", prop_lengthViaFoldLeft)
    , ("List.reverse", prop_reverse)
    , ("List.appendViaFoldRight", prop_appendViaFoldRight)
    , ("List.concat", prop_concat)
    , ("List.incrementEach", prop_incrementEach)
    , ("List.doubleToString", prop_doubleToString)
    , ("List.map", prop_map)
    , ("List.filter", prop_filter)
    , ("List.flatMap", prop_flatMap)
    , ("List.filterViaFlatMap", prop_filterViaFlatMap)
    , ("List.addPairwise", prop_addPairwise)
    , ("List.zipWith", prop_zipWith)
    , ("List.hasSubsequence (structured)", prop_hasSubsequence_structured)
    , ("List.hasSubsequence (random)", prop_hasSubsequence_random)
    , ("Tree.size", prop_Tree_size)
    , ("Tree.depth", prop_Tree_depth)
    , ("Tree.map", prop_Tree_map)
    , ("Tree.fold", prop_Tree_fold)
    , ("Tree.sizeViaFold", prop_Tree_sizeViaFold)
    , ("Tree.depthViaFold", prop_Tree_depthViaFold)
    , ("Tree.mapViaFold", prop_Tree_mapViaFold)
    , ("Tree.firstPositive", prop_Tree_firstPositive)
    , ("Tree.maximum", prop_Tree_maximum)
    , ("Tree.maximumViaFold", prop_Tree_maximumViaFold)
    ]
