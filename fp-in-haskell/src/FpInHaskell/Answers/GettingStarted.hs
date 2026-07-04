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

-- `$` を使うと括弧の記法を避けられる
printAbs :: IO ()
printAbs = putStrLn $ formatAbs (-42) -- `putStrLn (formatAbs (-42))` と同じ

-- ローカルな末尾再帰関数を使った factorial の定義
factorial :: Int -> Int
factorial n = go n 1
  where
    go n' acc = if n' <= 0 then acc else go (n' - 1) (n' * acc)

-- Exercise 2.1: n番目のフィボナッチ数を計算する関数 `fib` を定義せよ。
fib :: Int -> Int
fib n = go n 0 1
  where
    go n' current next = if n' <= 0 then current else go (n' - 1) next (current + next)

-- この定義は `formatAbs` とよく似ている。
formatFactorial :: Int -> String
formatFactorial n = "The factorial of " ++ show n ++ " is " ++ show (factorial n) ++ "."

-- `formatAbs` と `formatFactorial` を一般化して、_関数_ をパラメータとして受け取るようにする
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

-- 関数型プログラミングでは関数を取り回すことが多いため、
-- 名前を付けることなく関数を組み立てる構文があると便利だ
-- 無名関数の例:
printAnonymousFunctions :: IO ()
printAnonymousFunctions = do
    putStrLn (formatResult "absolute value" (-42) myAbs)
    putStrLn (formatResult "factorial" 7 factorial)
    putStrLn (formatResult "increment" 7 (\x -> x + 1))
    putStrLn (formatResult "increment2" 7 (\x -> x + 1))
    putStrLn (formatResult "increment3" 7 (\x -> x + 1))
    putStrLn (formatResult "increment4" 7 (+ 1))
    putStrLn (formatResult "increment5" 7 (\x -> let r = x + 1 in r))

-- まずは String に特化した findFirst。理想的には任意のリスト型に対して動作するよう一般化できる。
findFirstString :: [String] -> String -> Int
findFirstString ss key = go ss 0
  where
    -- リストが空になったら、キーが存在しないことを示す -1 を返す。
    go [] _ = -1
    -- 先頭要素 `x` を取り出し、`key` と一致すれば現在の位置 `n` を返す。
    -- そうでなければ残りのリスト `xs` で探し続ける。
    go (x : xs) n = if x == key then n else go xs (n + 1)

-- こちらは多相版の `findFirst`。探している要素かどうかをテストする関数でパラメータ化されている。
-- `String` をハードコードせず、型 `a` をパラメータとして受け取る。
-- また、特定のキーとの等値チェックをハードコードする代わりに、
-- リストの各要素をテストする関数を受け取る。
findFirst :: [a] -> (a -> Bool) -> Int
findFirst as p = go as 0
  where
    go [] _ = -1
    -- 関数 `p` が現在の要素にマッチしたら、合うものが見つかったということでリストのそのインデックスを返す。
    go (x : xs) n = if p x then n else go xs (n + 1)

-- Exercise 2.2: `[a]` がソート済みかどうかを判定する多相関数を定義せよ。
-- 第2引数 `gt` は `as` の隣接する2要素をとって最初の要素が2番目の要素より大きいかどうかを判定する述語関数。
isSorted :: [a] -> (a -> a -> Bool) -> Bool
isSorted as gt = go as
  where
    go [] = True
    go [_] = True
    go (x : y : rest) = if gt x y then False else go (y : rest)

-- 多相関数はたいてい型によって強く制約されているため、実装がひとつしかないことがある。その例:
partial1 :: a -> (a -> b -> c) -> b -> c
partial1 x f y = f x y

-- Exercise 2.3: `myCurry` を実装せよ。
-- `->` は右結合なので、戻り値の型は `a -> (b -> c)` とも書ける。
myCurry :: ((a, b) -> c) -> a -> b -> c
myCurry f x y = f (x, y)

-- Exercise 2.4: `myUncurry` を実装せよ。
myUncurry :: (a -> b -> c) -> (a, b) -> c
myUncurry f (x, y) = f x y

-- 補足: Prelude には `curry` と `uncurry` が用意されている。
--
-- カリー化とアンカリー化は行き来できる。両者はある意味で「同じ」であり、
-- FP の用語では _同型_ ("iso" = 同じ; "morphe" = 形、形式) と呼ぶ。
-- これは圏論から受け継いだ用語だ。

-- Exercise 2.5: `compose` を実装せよ。
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)
