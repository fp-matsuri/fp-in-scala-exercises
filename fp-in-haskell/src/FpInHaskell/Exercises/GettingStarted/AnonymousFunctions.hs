module FpInHaskell.Exercises.GettingStarted.AnonymousFunctions (
    printAnonymousFunctions,
) where

import FpInHaskell.Exercises.GettingStarted.MyProgram (abs, factorial, formatResult)
import Prelude hiding (abs)

-- 関数型プログラミングでは関数を取り回すことが多いため、
-- 名前を付けることなく関数を組み立てる構文があると便利だ
-- 無名関数の例:
printAnonymousFunctions :: IO ()
printAnonymousFunctions = do
    putStrLn (formatResult "absolute value" (-42) abs)
    putStrLn (formatResult "factorial" 7 factorial)
    putStrLn (formatResult "increment" 7 (\x -> x + 1))
    putStrLn (formatResult "increment2" 7 (\x -> x + 1))
    putStrLn (formatResult "increment3" 7 (\x -> x + 1))
    putStrLn (formatResult "increment4" 7 (+ 1)) -- `(+ 1)` は `+` の部分適用。`\x -> x + 1` と同じ
    putStrLn (formatResult "increment5" 7 (\x -> let r = x + 1 in r))
