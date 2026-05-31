module FpInHaskell.Answers.GettingStarted (
    myAbs,
    formatAbs,
    printAbs,
    factorial,
    fib,
    formatFactorial,
    formatResult,
    printAbsAndFactorial,
    printFib,
    printAnonymousFunctions,
    findFirstString,
    findFirst,
    isSorted,
    partial1,
    myCurry,
    myUncurry,
    compose,
) where

myAbs :: Int -> Int
myAbs n = if n < 0 then -n else n

formatAbs :: Int -> String
formatAbs x = "The absolute value of " ++ show x ++ " is " ++ show (myAbs x)

printAbs :: IO ()
printAbs = putStrLn (formatAbs (-42))

-- A definition of factorial, using a local, tail recursive function
factorial :: Int -> Int
factorial n = go n 1
  where
    go n' acc = if n' <= 0 then acc else go (n' - 1) (n' * acc)

-- Exercise 2.1: n番目のフィボナッチ数を計算する関数 `fib` を定義せよ。
fib :: Int -> Int
fib n = go n 0 1
  where
    go n' current next = if n' <= 0 then current else go (n' - 1) next (current + next)

-- This definition and `formatAbs` are very similar..
formatFactorial :: Int -> String
formatFactorial n = "The factorial of " ++ show n ++ " is " ++ show (factorial n) ++ "."

-- We can generalize `formatAbs` and `formatFactorial` to
-- accept a _function_ as a parameter
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
            ++ ", "
            ++ show (fib 1)
            ++ ", "
            ++ show (fib 2)
            ++ ", "
            ++ show (fib 3)
            ++ ", "
            ++ show (fib 4)
            ++ ", "
            ++ show (fib 5)
            ++ ", "
            ++ show (fib 6)
        )

-- Functions get passed around so often in FP that it's
-- convenient to have syntax for constructing a function
-- without having to give it a name
-- Some examples of anonymous functions:
printAnonymousFunctions :: IO ()
printAnonymousFunctions = do
    putStrLn (formatResult "absolute value" (-42) myAbs)
    putStrLn (formatResult "factorial" 7 factorial)
    putStrLn (formatResult "increment" 7 (\x -> x + 1))
    putStrLn (formatResult "increment2" 7 (\x -> x + 1))
    putStrLn (formatResult "increment3" 7 (\x -> x + 1))
    putStrLn (formatResult "increment4" 7 (+ 1))
    putStrLn (formatResult "increment5" 7 (\x -> let r = x + 1 in r))

-- First, a findFirst, specialized to String.
-- Ideally, we could generalize this to work for any Array type.
findFirstString :: [String] -> String -> Int
findFirstString ss key = go ss 0
  where
    -- If n is past the end of the array, return -1
    -- indicating the key doesn't exist in the array.
    go [] _ = -1
    -- ss(n) extracts the n'th element of the array ss.
    -- If the element at n is equal to the key, return n
    -- indicating that the element appears in the array at that index.
    -- Otherwise increment n and keep looking.
    go (x : xs) n = if x == key then n else go xs (n + 1)

-- Here's a polymorphic version of `findFirst`, parameterized on
-- a function for testing whether an `A` is the element we want to find.
-- Instead of hard-coding `String`, we take a type `A` as a parameter.
-- And instead of hard-coding an equality check for a given key,
-- we take a function with which to test each element of the array.
findFirst :: [a] -> (a -> Bool) -> Int
findFirst as p = go as 0
  where
    go [] _ = -1
    -- If the function `p` matches the current element,
    -- we've found a match and we return its index in the array.
    go (x : xs) n = if p x then n else go xs (n + 1)

-- Exercise 2.2: `[a]` がソート済みかどうかを判定する多相関数を定義せよ。
-- 第2引数 `gt` は `as` の隣接する2要素をとって最初の要素が2番目の要素より大きいかどうかを判定する述語関数。
isSorted :: [a] -> (a -> a -> Bool) -> Bool
isSorted as gt = go as
  where
    go [] = True
    go [_] = True
    go (x : y : rest) = if gt x y then False else go (y : rest)

-- Polymorphic functions are often so constrained by their type
-- that they only have one implementation! Here's an example:
partial1 :: a -> (a -> b -> c) -> b -> c
partial1 x f y = f x y

-- Exercise 2.3: `myCurry` を実装せよ。
-- `->` は右結合なので、戻り値の型は `a -> (b -> c)` とも書ける。
myCurry :: ((a, b) -> c) -> a -> b -> c
myCurry f x y = f (x, y)

-- Exercise 2.4: `myUncurry` を実装せよ。
myUncurry :: (a -> b -> c) -> (a, b) -> c
myUncurry f (x, y) = f x y

-- NB: There is a method on the `Function` object in the standard library,
-- `Function.uncurried` that you can use for uncurrying.
--
-- Note that we can go back and forth between the two forms. We can curry
-- and uncurry and the two forms are in some sense "the same". In FP jargon,
-- we say that they are _isomorphic_ ("iso" = same; "morphe" = shape, form),
-- a term we inherit from category theory.

-- Exercise 2.5: `compose` を実装せよ。
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)
