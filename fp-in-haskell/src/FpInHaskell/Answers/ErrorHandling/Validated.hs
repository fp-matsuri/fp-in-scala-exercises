module FpInHaskell.Answers.ErrorHandling.Validated (
    Validated (..),
    toEither,
    fromEither,
    map,
    map2,
    traverse,
    sequence,
) where

import FpInHaskell.Answers.ErrorHandling.Either (Either (Left, Right))
import Prelude hiding (Either (..), map, sequence, traverse)

-- `Validated` は `Either` に準じた型だが、`Invalid` が誤りを1つではなく**リストで**保持する点が異なる。
-- `map2` が両辺とも失敗のときにリストを連結することで、`Either.map2` と違って複数の誤りを
-- 蓄積できる(`Either.map2` は最初に出会った1つの誤りで打ち切ってしまう)。
-- この型自体には演習がなく(原典でも全関数が提供済み)、`Either` を補う参考実装として
-- Answers 側にのみ用意する。
data Validated e a
    = Valid a
    | Invalid [e]
    deriving (Show, Eq)

toEither :: Validated e a -> Either [e] a
toEither (Valid x) = Right x
toEither (Invalid es) = Left es

fromEither :: Either [e] a -> Validated e a
fromEither (Right x) = Valid x
fromEither (Left es) = Invalid es

map :: (a -> b) -> Validated e a -> Validated e b
map _ (Invalid es) = Invalid es
map f (Valid x) = Valid (f x)

-- 両辺が `Valid` のときだけ `f` を適用する。両辺とも `Invalid` なら、誤りのリストを連結して蓄積する
-- (`Either.map2` のように最初の誤りだけを返すのではない点に注意)。
map2 :: (a -> b -> c) -> Validated e a -> Validated e b -> Validated e c
map2 f (Valid x) (Valid y) = Valid (f x y)
map2 _ (Invalid es) (Valid _) = Invalid es
map2 _ (Valid _) (Invalid es) = Invalid es
map2 _ (Invalid es1) (Invalid es2) = Invalid (es1 ++ es2)

traverse :: (a -> Validated e b) -> [a] -> Validated e [b]
traverse _ [] = Valid []
traverse f (h : t) = map2 (:) (f h) (traverse f t)

sequence :: [Validated e a] -> Validated e [a]
sequence = traverse id
