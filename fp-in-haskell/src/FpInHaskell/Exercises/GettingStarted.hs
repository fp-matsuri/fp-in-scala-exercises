module FpInHaskell.Exercises.GettingStarted
  ( myAbs
  , formatAbs
  , printAbs
  , factorial
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
  , myCurry
  , myUncurry
  , compose
  ) where

myAbs :: Int -> Int
myAbs n = if n < 0 then -n else n

formatAbs :: Int -> String
formatAbs x = "The absolute value of " ++ show x ++ " is " ++ show (myAbs x)

printAbs :: IO ()
printAbs = putStrLn (formatAbs (-42))

factorial :: Int -> Int
factorial n = go n 1
  where
    go n' acc = if n' <= 0 then acc else go (n' - 1) (n' * acc)

-- Exercise 2.1: n番目のフィボナッチ数を計算する関数 `fib` を定義せよ。

fib :: Int -> Int
fib = undefined

formatFactorial :: Int -> String
formatFactorial n = "The factorial of " ++ show n ++ " is " ++ show (factorial n) ++ "."

formatResult :: String -> Int -> (Int -> Int) -> String
formatResult name n f = "The " ++ name ++ " of " ++ show n ++ " is " ++ show (f n) ++ "."

printAbsAndFactorial :: IO ()
printAbsAndFactorial = do
  putStrLn (formatResult "absolute value" (-42) myAbs)
  putStrLn (formatResult "factorial" 7 factorial)

printFib :: IO ()
printFib = do
  putStrLn "Expected: 0, 1, 1, 2, 3, 5, 8"
  putStrLn
    ( "Actual:   "
        ++ show (fib 0)
        ++ ", " ++ show (fib 1)
        ++ ", " ++ show (fib 2)
        ++ ", " ++ show (fib 3)
        ++ ", " ++ show (fib 4)
        ++ ", " ++ show (fib 5)
        ++ ", " ++ show (fib 6)
    )

printAnonymousFunctions :: IO ()
printAnonymousFunctions = do
  putStrLn (formatResult "absolute value" (-42) myAbs)
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

partial1 :: a -> (a -> b -> c) -> b -> c
partial1 x f y = f x y

-- Exercise 2.3: `myCurry` を実装せよ。
-- `->` は右結合なので、戻り値の型は `a -> (b -> c)` とも書ける。

myCurry :: ((a, b) -> c) -> a -> b -> c
myCurry = undefined

-- Exercise 2.4: `myUncurry` を実装せよ。

myUncurry :: (a -> b -> c) -> (a, b) -> c
myUncurry = undefined

-- Exercise 2.5: `compose` を実装せよ。

compose :: (b -> c) -> (a -> b) -> a -> c
compose = undefined
