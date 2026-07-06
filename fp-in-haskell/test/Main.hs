module Main (main) where

import qualified DataStructuresSpec
import qualified ErrorHandlingSpec
import qualified GettingStartedSpec
import System.Exit (exitFailure, exitSuccess)
import Test.QuickCheck (isSuccess, quickCheckResult)

main :: IO ()
main = do
    results <-
        mapM
            runProp
            (GettingStartedSpec.props ++ DataStructuresSpec.props ++ ErrorHandlingSpec.props)
    if all isSuccess results
        then exitSuccess
        else exitFailure
  where
    runProp (name, prop) = do
        putStrLn $ "=== " ++ name ++ " ==="
        quickCheckResult prop
