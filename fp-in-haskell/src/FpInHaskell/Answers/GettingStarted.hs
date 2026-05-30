module FpInHaskell.Answers.GettingStarted
  ( abs
  , factorial
  , fib
  , isSorted
  , curry
  , uncurry
  , compose
  ) where

import Prelude hiding (abs, curry, uncurry)

abs :: Int -> Int
abs = undefined

factorial :: Int -> Int
factorial = undefined

fib :: Int -> Int
fib = undefined

isSorted :: [a] -> (a -> a -> Bool) -> Bool
isSorted = undefined

curry :: ((a, b) -> c) -> a -> b -> c
curry = undefined

uncurry :: (a -> b -> c) -> (a, b) -> c
uncurry = undefined

compose :: (b -> c) -> (a -> b) -> a -> c
compose = undefined
