module FpInHaskell.Answers.GettingStarted.TestFib (
    printFib,
) where

import FpInHaskell.Answers.GettingStarted.MyProgram (fib)

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
