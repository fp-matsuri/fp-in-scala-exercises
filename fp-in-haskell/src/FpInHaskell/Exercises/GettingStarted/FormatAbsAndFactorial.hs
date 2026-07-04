module FpInHaskell.Exercises.GettingStarted.FormatAbsAndFactorial (
    formatAbs,
    printAbs,
    formatFactorial,
    printAbsAndFactorial,
) where

import FpInHaskell.Exercises.GettingStarted.MyProgram (abs, factorial, formatResult)
import Prelude hiding (abs)

formatAbs :: Int -> String
formatAbs x = "The absolute value of " ++ show x ++ " is " ++ show (abs x)

-- `$` を使うと括弧の記法を避けられる
printAbs :: IO ()
printAbs = putStrLn $ formatAbs (-42) -- `putStrLn (formatAbs (-42))` と同じ

-- この定義は `formatAbs` とよく似ている。
formatFactorial :: Int -> String
formatFactorial n = "The factorial of " ++ show n ++ " is " ++ show (factorial n) ++ "."

printAbsAndFactorial :: IO ()
printAbsAndFactorial = do
    putStrLn (formatResult "absolute value" (-42) abs)
    putStrLn (formatResult "factorial" 7 factorial)
