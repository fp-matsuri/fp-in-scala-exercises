module Main (main) where

import GettingStartedSpec (props)
import System.Exit (exitFailure, exitSuccess)
import Test.QuickCheck (isSuccess, quickCheckResult)

main :: IO ()
main = do
  results <- mapM runProp props
  if all isSuccess results
    then exitSuccess
    else exitFailure
  where
    runProp (name, prop) = do
      putStrLn $ "=== " ++ name ++ " ==="
      quickCheckResult prop
