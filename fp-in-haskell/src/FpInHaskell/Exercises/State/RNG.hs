module FpInHaskell.Exercises.State.RNG (
    RNG (..),
    nextInt,
    Rand,
    int,
    unit,
    map,
    nonNegativeInt,
    double,
    boolean,
    intDouble,
    doubleInt,
    double3,
    ints,
    doubleViaMap,
    map2,
    sequence,
    flatMap,
    nonNegativeLessThan,
    mapViaFlatMap,
    map2ViaFlatMap,
) where

import Data.Bits (shiftR, (.&.))
import Data.Int (Int32)
import Data.Word (Word64)
import Prelude hiding (map, sequence)

-- 乱数生成器。Scala 版は `trait RNG { def nextInt: (Int, RNG) }` として抽象化し、
-- `Simple` はその実装の1つという位置づけだが、この演習では `Simple` しか使わないため、
-- 型クラスや抽象データ型で一般化せず、具体的な `newtype` として素直に定義する。
newtype RNG = Simple Word64
    deriving (Show)

-- Javaの `java.util.Random` と同じ線形合同法(LCG)。48bit のシード値を使う。
-- `newSeed` は `Word64` 上で48bitマスクして計算するが、返す乱数 `n` は32bit符号付き整数
-- (`Int32`)として解釈しなければならない(Scala 版の `.toInt` は32bit話幅への切り詰めであり、
-- 32bit目が立っていれば負の値になる)。そのため一度 `Int32` を経由してから `Int` へ拡張する。
nextInt :: RNG -> (Int, RNG)
nextInt (Simple seed) = (n, Simple newSeed)
  where
    newSeed = (seed * 0x5DEECE66D + 0xB) .&. 0xFFFFFFFFFFFF
    n = fromIntegral (fromIntegral (newSeed `shiftR` 16) :: Int32)

-- `RNG` を状態として持ち回す計算を表す型。
type Rand a = RNG -> (a, RNG)

int :: Rand Int
int = nextInt

unit :: a -> Rand a
unit a rng = (a, rng)

-- Prelude の `map` と同じ引数順(関数、Rand の順)。
map :: (a -> b) -> Rand a -> Rand b
map f s rng = let (a, rng2) = s rng in (f a, rng2)

-- Exercise 6.1: 非負整数をランダム生成する関数 `nonNegativeInt` を実装せよ。

nonNegativeInt :: RNG -> (Int, RNG)
nonNegativeInt = undefined

-- Exercise 6.2: 0以上1未満の浮動小数点数をランダム生成する関数 `double` を実装せよ。

double :: RNG -> (Double, RNG)
double = undefined

boolean :: RNG -> (Bool, RNG)
boolean rng = let (i, rng2) = nextInt rng in (even i, rng2)

-- Exercise 6.3: 整数と浮動小数点数の組をランダム生成する関数 `intDouble` と `doubleInt` を実装せよ。
-- また、浮動小数点数の3つ組をランダム生成する関数 `double3` を実装せよ。

intDouble :: RNG -> ((Int, Double), RNG)
intDouble = undefined

doubleInt :: RNG -> ((Double, Int), RNG)
doubleInt = undefined

double3 :: RNG -> ((Double, Double, Double), RNG)
double3 = undefined

-- Exercise 6.4: 引数で指定された要素数の整数リストをランダム生成する関数 `ints` を実装せよ。

ints :: Int -> RNG -> ([Int], RNG)
ints = undefined

-- Exercise 6.5: `map` を用いて `double` を実装せよ。

doubleViaMap :: Rand Double
doubleViaMap = undefined

-- Exercise 6.6: 関数 `map2` を実装せよ。

map2 :: (a -> b -> c) -> Rand a -> Rand b -> Rand c
map2 = undefined

-- Exercise 6.7: 関数 `sequence` を実装せよ。

sequence :: [Rand a] -> Rand [a]
sequence = undefined

-- Exercise 6.8: 関数 `flatMap` を実装せよ。

flatMap :: (a -> Rand b) -> Rand a -> Rand b
flatMap = undefined

-- `flatMap` の使用例。演習番号はないが(Either.map2All 等と同様の位置づけ)、`flatMap` の
-- テスト対象として実装する。`n` 未満の非負整数を、偏りが出ないように再試行しながら生成する。

nonNegativeLessThan :: Int -> Rand Int
nonNegativeLessThan n = flatMap go nonNegativeInt
  where
    go i =
        let m = i `mod` n
         in if i + (n - 1) - m >= 0 then unit m else nonNegativeLessThan n

-- Exercise 6.9: `flatMap` を用いて `map`, `map2` を実装せよ。

mapViaFlatMap :: (a -> b) -> Rand a -> Rand b
mapViaFlatMap = undefined

map2ViaFlatMap :: (a -> b -> c) -> Rand a -> Rand b -> Rand c
map2ViaFlatMap = undefined
