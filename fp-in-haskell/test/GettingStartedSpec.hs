module GettingStartedSpec
  ( props
  ) where

import FpInHaskell.Answers.GettingStarted (compose, factorial, fib, isSorted)
import qualified FpInHaskell.Answers.GettingStarted as G (curry, uncurry)
import FpInHaskell.Test.Common
import Test.QuickCheck

prop_factorial :: Property
prop_factorial = forAll genSmallInt $ \n ->
  factorial n === product [1 .. n]

prop_fib :: Property
prop_fib = forAll genLengthOfFibonacciSeq $ \i ->
  fib i === firstFibs !! i

prop_isSorted_sorted :: Property
prop_isSorted_sorted = forAll genSorted $ \xs ->
  isSorted xs (>) === True

prop_isSorted_unsorted :: Property
prop_isSorted_unsorted = forAll genUnsorted $ \xs ->
  isSorted xs (>) === False

prop_curry :: Property
prop_curry = forAll (arbitrary :: Gen (Int, Int)) $ \(n, m) ->
  G.curry (\(a, b) -> a * b) n m === n * m

prop_uncurry :: Property
prop_uncurry = forAll (arbitrary :: Gen (Int, Int)) $ \(n, m) ->
  G.uncurry (*) (n, m) === n * m

prop_compose :: Property
prop_compose = forAll (arbitrary :: Gen (Int, Int)) $ \(n, m) ->
  compose (* n) (* m) 1 === n * m

props :: [(String, Property)]
props =
  [ ("MyProgram.factorial", prop_factorial)
  , ("MyProgram.fib", prop_fib)
  , ("PolymorphicFunctions.isSorted for sorted list case", prop_isSorted_sorted)
  , ("PolymorphicFunctions.isSorted for unsorted list case", prop_isSorted_unsorted)
  , ("PolymorphicFunctions.curry", prop_curry)
  , ("PolymorphicFunctions.uncurry", prop_uncurry)
  , ("PolymorphicFunctions.compose", prop_compose)
  ]
