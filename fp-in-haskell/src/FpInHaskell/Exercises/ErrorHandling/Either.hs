module FpInHaskell.Exercises.ErrorHandling.Either (
    Either (..),
    map,
    flatMap,
    orElse,
    map2,
    traverse,
    sequence,
    mean,
    safeDiv,
    catchNonFatal,
    map2All,
    traverseAll,
    sequenceAll,
) where

import Control.Exception (ArithException (DivideByZero), SomeException, catch, evaluate)
import Prelude hiding (Either (..), either, map, sequence, traverse)

-- `Either` 型。Prelude にも同名の型と `either` 関数があるため hide している。
-- Scala 版に倣い、右側(`Right`)を正常値として扱う right-biased な設計にする
-- (Prelude の `Either` の `Functor`/`Monad` インスタンスも同じく right-biased なので、
-- 実は考え方は完全に共通している)。
data Either e a
    = Left e
    | Right a
    deriving (Show, Eq)

-- Exercise 4.6: Option に準じて `map`, `flatMap`, `orElse`, `map2` を実装せよ。

map :: (a -> b) -> Either e a -> Either e b
map = undefined

flatMap :: (a -> Either e b) -> Either e a -> Either e b
flatMap = undefined

-- 第1引数がフォールバック、第2引数が本体の Either(Option.orElse と同じ並び)。

orElse :: Either e a -> Either e a -> Either e a
orElse = undefined

map2 :: (a -> b -> c) -> Either e a -> Either e b -> Either e c
map2 = undefined

-- Exercise 4.7: Option に準じて `traverse`, `sequence` を実装せよ。

traverse :: (a -> Either e b) -> [a] -> Either e [b]
traverse = undefined

sequence :: [Either e a] -> Either e [a]
sequence = undefined

mean :: [Double] -> Either String Double
mean [] = Left "mean of empty list!"
mean xs = Right (sum xs / fromIntegral (length xs))

-- Haskell では 0 除算が例外を投げる代わりに、事前条件をそのまま純粋にチェックできる。
safeDiv :: Int -> Int -> Either ArithException Int
safeDiv _ 0 = Left DivideByZero
safeDiv x y = Right (x `div` y)

-- Scala 版は `a: => A`(遅延評価される任意の式)を受け取り、例外を捕捉して `Either` に変換する。
-- Haskell では、任意の式を安全に捕捉するには `IO` の中で `evaluate`/`catch` を使うしかない。
catchNonFatal :: a -> IO (Either SomeException a)
catchNonFatal a = (Right <$> evaluate a) `catch` (return . Left)

-- 原典 Scala 版ではここに演習番号は振られていないが(Tree.firstPositive と同様、番号なしのスタブ)、
-- 実際にはテスト対象の演習である。誤りを蓄積する版の `map2All`/`traverseAll`/`sequenceAll` を実装せよ。
-- `Left` の中身をリストにして、両方失敗していれば連結する。

map2All :: (a -> b -> c) -> Either [e] a -> Either [e] b -> Either [e] c
map2All = undefined

traverseAll :: (a -> Either [e] b) -> [a] -> Either [e] [b]
traverseAll = undefined

sequenceAll :: [Either [e] a] -> Either [e] [a]
sequenceAll = undefined
