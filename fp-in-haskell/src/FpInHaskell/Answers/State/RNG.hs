module FpInHaskell.Answers.State.RNG (
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

-- Prelude には同名の `map`/`sequence` がすでにあるため、上の `import Prelude hiding (...)` で
-- それらを読み込み対象から外し、ここでは `Rand` に対する同名の演習関数を自前で定義している。

-- 乱数生成器。この演習では単一の実装(線形合同法)しか使わないため、型クラスや抽象データ型で
-- 一般化せず、具体的な `newtype` として素直に定義する。
newtype RNG = Simple Word64
    deriving (Show)

-- Javaの `java.util.Random` と同じ線形合同法(LCG)。48bit のシード値を使う。
-- `newSeed` は `Word64` 上で48bitマスクして計算するが、返す乱数 `n` は32bit符号付き整数
-- (`Int32`)として解釈しなければならない(32bit目が立っていれば負の値になる)。
-- そのため一度 `Int32` を経由してから `Int` へ拡張する。
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
unit x rng = (x, rng)

-- Prelude の `map` と同じ引数順(関数、Rand の順)。
map :: (a -> b) -> Rand a -> Rand b
map f s rng = let (x, rng2) = s rng in (f x, rng2)

-- Exercise 6.1: 非負整数をランダム生成する関数 `nonNegativeInt` を実装せよ。
--
-- `minBound :: Int` の絶対値は `maxBound :: Int` より1大きいため、負の数に1を足してから
-- 正の数にする。これにより `minBound` は `maxBound` に、`-1` は `0` に写る。
nonNegativeInt :: RNG -> (Int, RNG)
nonNegativeInt rng =
    let (i, r) = nextInt rng
     in (if i < 0 then -(i + 1) else i, r)

-- Exercise 6.2: 0以上1未満の浮動小数点数をランダム生成する関数 `double` を実装せよ。
double :: RNG -> (Double, RNG)
double rng =
    let (i, r) = nonNegativeInt rng
     in (fromIntegral i / (fromIntegral (maxBound :: Int) + 1), r)

boolean :: RNG -> (Bool, RNG)
boolean rng = let (i, rng2) = nextInt rng in (even i, rng2)

-- Exercise 6.3: 整数と浮動小数点数の組をランダム生成する関数 `intDouble` と `doubleInt` を実装せよ。
-- また、浮動小数点数の3つ組をランダム生成する関数 `double3` を実装せよ。
intDouble :: RNG -> ((Int, Double), RNG)
intDouble rng =
    let (i, r1) = nextInt rng
        (d, r2) = double r1
     in ((i, d), r2)

doubleInt :: RNG -> ((Double, Int), RNG)
doubleInt rng =
    let ((i, d), r) = intDouble rng
     in ((d, i), r)

double3 :: RNG -> ((Double, Double, Double), RNG)
double3 rng =
    let (d1, r1) = double rng
        (d2, r2) = double r1
        (d3, r3) = double r2
     in ((d1, d2, d3), r3)

-- Exercise 6.4: 引数で指定された要素数の整数リストをランダム生成する関数 `ints` を実装せよ。
ints :: Int -> RNG -> ([Int], RNG)
ints count rng
    | count <= 0 = ([], rng)
    | otherwise =
        let (x, r1) = nextInt rng
            (xs, r2) = ints (count - 1) r1
         in (x : xs, r2)

-- Exercise 6.5: `map` を用いて `double` を実装せよ。
doubleViaMap :: Rand Double
doubleViaMap = map (\i -> fromIntegral i / (fromIntegral (maxBound :: Int) + 1)) nonNegativeInt

-- Exercise 6.6: 関数 `map2` を実装せよ。
map2 :: (a -> b -> c) -> Rand a -> Rand b -> Rand c
map2 f ra rb rng0 =
    let (x, rng1) = ra rng0
        (y, rng2) = rb rng1
     in (f x y, rng2)

-- Exercise 6.7: 関数 `sequence` を実装せよ。
sequence :: [Rand a] -> Rand [a]
sequence = foldr (\r acc -> map2 (:) r acc) (unit [])

-- Exercise 6.8: 関数 `flatMap` を実装せよ。
flatMap :: (a -> Rand b) -> Rand a -> Rand b
flatMap f r rng0 = let (x, rng1) = r rng0 in f x rng1

-- `flatMap` の使用例。演習番号はないが、`flatMap` の使い方の見本として Answers/Exercises
-- 両方で実装しておく。`n` 未満の非負整数を、偏りが出ないように再試行しながら生成する。
nonNegativeLessThan :: Int -> Rand Int
nonNegativeLessThan n = flatMap go nonNegativeInt
  where
    go i =
        let m = i `mod` n
         in if i + (n - 1) - m >= 0 then unit m else nonNegativeLessThan n

-- Exercise 6.9: `flatMap` を用いて `map`, `map2` を実装せよ。
mapViaFlatMap :: (a -> b) -> Rand a -> Rand b
mapViaFlatMap f = flatMap (unit . f)

map2ViaFlatMap :: (a -> b -> c) -> Rand a -> Rand b -> Rand c
map2ViaFlatMap f ra rb = flatMap (\x -> map (f x) rb) ra
