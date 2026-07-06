module FpInHaskell.Answers.ErrorHandling.Either (
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
-- 右側(`Right`)を正常値として扱う right-biased な設計にする
-- (Prelude の `Either` の `Functor`/`Monad` インスタンスも同じく right-biased である)。
data Either e a
    = Left e
    | Right a
    deriving (Show, Eq)

-- Exercise 4.6: Option に準じて `map`, `flatMap`, `orElse`, `map2` を実装せよ。
map :: (a -> b) -> Either e a -> Either e b
map _ (Left err) = Left err
map f (Right x) = Right (f x)

flatMap :: (a -> Either e b) -> Either e a -> Either e b
flatMap _ (Left err) = Left err
flatMap f (Right x) = f x

-- 第1引数がフォールバック、第2引数が本体の Either(Option.orElse と同じ並び)。
orElse :: Either e a -> Either e a -> Either e a
orElse fallback (Left _) = fallback
orElse _ right = right

map2 :: (a -> b -> c) -> Either e a -> Either e b -> Either e c
map2 f ea eb = flatMap (\x -> map (f x) eb) ea

-- Exercise 4.7: Option に準じて `traverse`, `sequence` を実装せよ。
traverse :: (a -> Either e b) -> [a] -> Either e [b]
traverse _ [] = Right []
traverse f (h : t) = map2 (:) (f h) (traverse f t)

sequence :: [Either e a] -> Either e [a]
sequence = traverse id

mean :: [Double] -> Either String Double
mean [] = Left "mean of empty list!"
mean xs = Right (sum xs / fromIntegral (length xs))

-- Haskell では 0 除算が例外を投げる代わりに、事前条件をそのまま純粋にチェックできる。
-- `catchNonFatal` のように任意の計算を包括的に捕捉する必要はなく、
-- 特定の条件(除数が0)だけを見ればよいため、例外機構に頼らないほうが自然で単純になる。
safeDiv :: Int -> Int -> Either ArithException Int
safeDiv _ 0 = Left DivideByZero
safeDiv x y = Right (x `div` y)

-- 任意の式を評価し、例外を捕捉して `Either` に変換する。`safeDiv` のように特定の失敗条件だけを
-- 見る形にはできない汎用的な捕捉なので、`IO` の中で `evaluate`/`catch` を使うしかない。
catchNonFatal :: a -> IO (Either SomeException a)
catchNonFatal x = (Right <$> evaluate x) `catch` (return . Left)

-- 原典ではここに演習番号は振られていないが(Tree.firstPositive と同様、番号なしのスタブ)、
-- 実際にはテスト対象の演習である。誤りを蓄積する版。`Left` の中身をリストにして、
-- 両方失敗していれば連結する。
map2All :: (a -> b -> c) -> Either [e] a -> Either [e] b -> Either [e] c
map2All f (Right x) (Right y) = Right (f x y)
map2All _ (Left es) (Right _) = Left es
map2All _ (Right _) (Left es) = Left es
map2All _ (Left es1) (Left es2) = Left (es1 ++ es2)

traverseAll :: (a -> Either [e] b) -> [a] -> Either [e] [b]
traverseAll _ [] = Right []
traverseAll f (h : t) = map2All (:) (f h) (traverseAll f t)

sequenceAll :: [Either [e] a] -> Either [e] [a]
sequenceAll = traverseAll id
