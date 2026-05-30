module FpInHaskell.Exercises.GettingStarted
  ( abs
  , formatAbs
  , printAbs
  , factorial
  , factorial2
  , fib
  , formatFactorial
  , formatResult
  , printAbsAndFactorial
  , printFib
  , printAnonymousFunctions
  , findFirstString
  , findFirst
  , isSorted
  , partial1
  , curry
  , uncurry
  , compose
  ) where

import Prelude hiding (abs, curry, uncurry)
import Text.Printf (printf)

abs :: Int -> Int
abs n = if n < 0 then -n else n

formatAbs :: Int -> String
formatAbs x = printf "The absolute value of %d is %d" x (abs x)

printAbs :: IO ()
printAbs = putStrLn (formatAbs (-42))

factorial :: Int -> Int
factorial n = go n 1
  where
    go n' acc = if n' <= 0 then acc else go (n' - 1) (n' * acc)

factorial2 :: Int -> Int
factorial2 n = product [1 .. n]

-- Exercise 2.1: n番目のフィボナッチ数を計算する関数 `fib` を定義せよ。

fib :: Int -> Int
fib = undefined

formatFactorial :: Int -> String
formatFactorial n = printf "The factorial of %d is %d." n (factorial n)

formatResult :: String -> Int -> (Int -> Int) -> String
formatResult name n f = printf "The %s of %d is %d." name n (f n)

printAbsAndFactorial :: IO ()
printAbsAndFactorial = do
  putStrLn (formatResult "absolute value" (-42) abs)
  putStrLn (formatResult "factorial" 7 factorial)

printFib :: IO ()
printFib = do
  putStrLn "Expected: 0, 1, 1, 2, 3, 5, 8"
  putStrLn
    ( printf
        "Actual:   %d, %d, %d, %d, %d, %d, %d"
        (fib 0)
        (fib 1)
        (fib 2)
        (fib 3)
        (fib 4)
        (fib 5)
        (fib 6)
    )

printAnonymousFunctions :: IO ()
printAnonymousFunctions = do
  putStrLn (formatResult "absolute value" (-42) abs)
  putStrLn (formatResult "factorial" 7 factorial)
  putStrLn (formatResult "increment" 7 (\x -> x + 1))
  putStrLn (formatResult "increment2" 7 (\x -> x + 1))
  putStrLn (formatResult "increment3" 7 (\x -> x + 1))
  putStrLn (formatResult "increment4" 7 (+ 1))
  putStrLn (formatResult "increment5" 7 (\x -> let r = x + 1 in r))

findFirstString :: [String] -> String -> Int
findFirstString ss key = go ss 0
  where
    go [] _ = -1
    go (x : xs) n = if x == key then n else go xs (n + 1)

findFirst :: [a] -> (a -> Bool) -> Int
findFirst as p = go as 0
  where
    go [] _ = -1
    go (x : xs) n = if p x then n else go xs (n + 1)

-- Exercise 2.2: `[a]` がソート済みかどうかを判定する多相関数を定義せよ。
-- 第2引数 `gt` は `as` の隣接する2要素をとって最初の要素が2番目の要素より大きいかどうかを判定する述語関数。

isSorted :: [a] -> (a -> a -> Bool) -> Bool
isSorted = undefined

partial1 :: a -> ((a, b) -> c) -> b -> c
partial1 a f b = f (a, b)

-- Exercise 2.3: `curry` を実装せよ。

-- Note that `=>` associates to the right, so we could
-- write the return type as `a => b => c`
curry :: ((a, b) -> c) -> a -> b -> c
curry = undefined

-- Exercise 2.4: `uncurry` を実装せよ。

uncurry :: (a -> b -> c) -> (a, b) -> c
uncurry = undefined

-- Exercise 2.5: `compose` を実装せよ。

compose :: (b -> c) -> (a -> b) -> a -> c
compose = undefined
