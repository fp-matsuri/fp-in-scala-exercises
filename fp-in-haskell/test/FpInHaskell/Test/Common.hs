module FpInHaskell.Test.Common
  ( firstFibs
  , genLengthOfFibonacciSeq
  , genSmallInt
  , genSorted
  , genUnsorted
  ) where

import Data.List (sort)
import Test.QuickCheck

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
