module StateSpec (
    props,
) where

import Data.List (nub)
import FpInHaskell.Exercises.State.Candy (Input (Coin, Turn), Machine (Machine, candies, coins, locked))
import qualified FpInHaskell.Exercises.State.Candy as Candy
import FpInHaskell.Exercises.State.RNG (RNG)
import qualified FpInHaskell.Exercises.State.RNG as RNG
import FpInHaskell.Exercises.State.State (State (State), runState)
import qualified FpInHaskell.Exercises.State.State as ST
import FpInHaskell.Test.Common
import Test.QuickCheck
import Text.Read (readMaybe)

-- ch3-5 の Spec と同じ理由で、演習対象のモジュールだけを修飾 import している(`RNG.`/`ST.`/`Candy.`)。

genCounter :: Gen Int
genCounter = choose (10, 100)

genLengthOfList :: Gen Int
genLengthOfList = choose (-5, 20)

isInInterval :: Double -> Bool
isInInterval d = 0 <= d && d < 1

-- Scala 版 `checkRND` に相当する。`gen` を `counter` 回繰り返し適用し、各結果が `isCorrect` を
-- 満たすこと、かつ連続する2回の結果が(ほぼ確実に)一致しないことを確認する。
checkRand :: (Eq a) => RNG -> Int -> (RNG -> (a, RNG)) -> (a -> Bool) -> Bool
checkRand rng0 counter0 gen isCorrect = go rng0 counter0 Nothing
  where
    go _ counter _ | counter < 0 = True
    go rng counter prevValue =
        let (value, rng2) = gen rng
         in isCorrect value && prevValue /= Just value && go rng2 (counter - 1) (Just value)

-- `checkRand` から連続する2回の結果が一致しないことの確認を除いたもの。
-- `RNG.unit`(常に同じ定数を返す)や `RNG.nonNegativeLessThan`(`limit` が小さいと
-- 偶然の一致がありうる)のように、そもそも連続する値が一致しうる場合に使う
-- (Scala 版が `checkRNGUnit`/`checkRNGNonNegativeLessThan` を別に用意しているのと同じ理由)。
checkRandRange :: RNG -> Int -> (RNG -> (a, RNG)) -> (a -> Bool) -> Bool
checkRandRange rng0 counter0 gen isCorrect = go rng0 counter0
  where
    go _ counter | counter < 0 = True
    go rng counter =
        let (value, rng2) = gen rng
         in isCorrect value && go rng2 (counter - 1)

prop_RNG_nextInt :: Property
prop_RNG_nextInt = forAll genRNG $ \rng ->
    let (n1, rng2) = RNG.nextInt rng
        (n2, rng3) = RNG.nextInt rng2
        (n3, _) = RNG.nextInt rng3
        (n4, _) = RNG.nextInt rng
        (n5, _) = RNG.nextInt rng2
     in n1
            /= n2
            .&&. n1
                /= n3
            .&&. n1
                === n4
            .&&. n2
                /= n3
            .&&. n2
                === n5

prop_RNG_nonNegativeInt :: Property
prop_RNG_nonNegativeInt = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter RNG.nonNegativeInt (>= 0)

prop_RNG_double :: Property
prop_RNG_double = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter RNG.double isInInterval

prop_RNG_intDouble :: Property
prop_RNG_intDouble = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter RNG.intDouble (\(_, d) -> isInInterval d)

prop_RNG_doubleInt :: Property
prop_RNG_doubleInt = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter RNG.doubleInt (\(d, _) -> isInInterval d)

prop_RNG_double3 :: Property
prop_RNG_double3 = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter RNG.double3 $ \(d1, d2, d3) ->
        isInInterval d1 && isInInterval d2 && isInInterval d3 && d1 /= d2 && d1 /= d3 && d2 /= d3

prop_RNG_ints :: Property
prop_RNG_ints = forAll ((,,) <$> genRNG <*> genCounter <*> genLengthOfList) $ \(rng, counter, n) ->
    if n <= 0
        then null (fst (RNG.ints n rng))
        else checkRand rng counter (RNG.ints n) (\xs -> xs == nub xs)

prop_RNG_int :: Property
prop_RNG_int = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter RNG.int (const True)

-- Scala 版の `checkRNGUnit` に相当。`unit` は状態に関わらず常に同じ値を返す。
prop_RNG_unit :: Property
prop_RNG_unit = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRandRange rng counter (RNG.unit (42 :: Int)) (== 42)

prop_RNG_map :: Property
prop_RNG_map = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter (RNG.map show RNG.int) (\s -> case readMaybe s :: Maybe Int of Just _ -> True; Nothing -> False)

-- Scala 本家はこの `_double`(このポートでの `doubleViaMap`)のテストをコメントアウトしているが、
-- 実際の演習(6.5)なのでテストする。
prop_RNG_doubleViaMap :: Property
prop_RNG_doubleViaMap = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter RNG.doubleViaMap isInInterval

prop_RNG_map2 :: Property
prop_RNG_map2 = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter (RNG.map2 (,) RNG.double RNG.double) $ \(d1, d2) ->
        isInInterval d1 && isInInterval d2 && d1 /= d2

prop_RNG_sequence :: Property
prop_RNG_sequence = forAll ((,,) <$> genRNG <*> genCounter <*> genLengthOfList) $ \(rng, counter, n) ->
    let rs = RNG.sequence (replicate n RNG.int)
     in if n <= 0
            then null (fst (rs rng))
            else checkRand rng counter rs (\xs -> xs == nub xs)

prop_RNG_flatMap :: Property
prop_RNG_flatMap = forAll ((,,) <$> genRNG <*> genCounter <*> choose (1, 1000)) $ \(rng, counter, limit) ->
    checkRandRange rng counter (RNG.nonNegativeLessThan limit) (\i -> 0 <= i && i < limit)

prop_RNG_mapViaFlatMap :: Property
prop_RNG_mapViaFlatMap = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter (RNG.mapViaFlatMap show RNG.int) (\s -> case readMaybe s :: Maybe Int of Just _ -> True; Nothing -> False)

prop_RNG_map2ViaFlatMap :: Property
prop_RNG_map2ViaFlatMap = forAll ((,) <$> genRNG <*> genCounter) $ \(rng, counter) ->
    checkRand rng counter (RNG.map2ViaFlatMap (,) RNG.double RNG.double) $ \(d1, d2) ->
        isInInterval d1 && isInInterval d2 && d1 /= d2

-- State.hs のテスト。Scala 版に倣い、文字列のリストを状態とする2つの State 値を使う。
genStringListPlain :: Gen [String]
genStringListPlain = listOf (listOf (choose ('a', 'z')))

-- a: 先頭要素、次の状態: リストの残り
stateA :: State [String] (Maybe String)
stateA = State $ \s -> case s of
    [] -> (Nothing, [])
    (h : t) -> (Just h, t)

-- b: リストの長さ、次の状態: リストの残り
stateB :: State [String] Int
stateB = State $ \s -> case s of
    [] -> (0, [])
    (h : t) -> (length t + 1, t)

lengthOfMaybe :: Maybe String -> Int
lengthOfMaybe = maybe 0 length

printResult :: Maybe String -> Int -> String
printResult h n = "The head element is '" ++ show h ++ "', the length is " ++ show n

prop_State_unit :: Property
prop_State_unit = forAll ((,) <$> arbitrary <*> (arbitrary :: Gen Int)) $ \(str, s) ->
    runState (ST.unit str) s === (str :: String, s)

prop_State_map :: Property
prop_State_map = forAll genStringListPlain $ \list ->
    let (b, s) = runState (ST.map lengthOfMaybe stateA) list
        expectedB = lengthOfMaybe (headMaybe list)
     in (b, s) === (expectedB, drop 1 list)
  where
    headMaybe [] = Nothing
    headMaybe (h : _) = Just h

prop_State_map2 :: Property
prop_State_map2 = forAll genStringListPlain $ \list ->
    let (c, s) = runState (ST.map2 printResult stateA stateB) list
        expectedC = printResult (headMaybe list) (length (drop 1 list))
     in (c, s) === (expectedC, drop 2 list)
  where
    headMaybe [] = Nothing
    headMaybe (h : _) = Just h

prop_State_flatMap :: Property
prop_State_flatMap = forAll genStringListPlain $ \list ->
    let (b, s) = runState (ST.flatMap (ST.unit . lengthOfMaybe) stateA) list
        expectedB = lengthOfMaybe (headMaybe list)
     in (b, s) === (expectedB, drop 1 list)
  where
    headMaybe [] = Nothing
    headMaybe (h : _) = Just h

prop_State_sequence :: Property
prop_State_sequence = forAll genStringListPlain $ \list ->
    let half = length list `div` 2
        listOfStates = replicate half stateA
        (firstHalfElements, restElements) = runState (ST.sequence listOfStates) list
        (first, rest) = splitAt half list
     in (firstHalfElements, restElements) === (map Just first, rest)

-- `traverse` は Scala 版のテストにはないが、演習6.10の一部なのでテストする。
-- 状態(カウンタ)を1つずつ増やしながら、その時点のカウンタ値を集める。
prop_State_traverse :: Property
prop_State_traverse = forAll (listOf (arbitrary :: Gen ())) $ \xs ->
    let (results, finalState) = runState (ST.traverse (const bumpAndGet) xs) (0 :: Int)
     in (results, finalState) === ([1 .. length xs], length xs)
  where
    bumpAndGet = ST.flatMap (const ST.get) (ST.modify (+ 1))

prop_Candy_outOfCandy :: Property
prop_Candy_outOfCandy = forAll ((,) <$> genInputList <*> genNoCandiesMachine) $ \(inputs, machine) ->
    let ((coinsOut, candiesOut), machine1) = runState (Candy.simulateMachine inputs) machine
     in candiesOut === 0 .&&. coinsOut === coins machine .&&. machine1 === machine

prop_Candy_coinIntoLocked :: Property
prop_Candy_coinIntoLocked = forAll genLockedMachine $ \machine ->
    let ((coinsOut, candiesOut), machine1) = runState (Candy.simulateMachine [Coin]) machine
     in candiesOut
            === candies machine
            .&&. coinsOut
                === coins machine + 1
            .&&. machine1
                === Machine False candiesOut coinsOut

prop_Candy_turnOnLocked :: Property
prop_Candy_turnOnLocked = forAll genLockedMachine $ \machine ->
    let ((coinsOut, candiesOut), machine1) = runState (Candy.simulateMachine [Turn]) machine
     in candiesOut === candies machine .&&. coinsOut === coins machine .&&. machine1 === machine

prop_Candy_coinIntoUnlocked :: Property
prop_Candy_coinIntoUnlocked = forAll genUnlockedMachine $ \machine ->
    let ((coinsOut, candiesOut), machine1) = runState (Candy.simulateMachine [Coin]) machine
     in candiesOut === candies machine .&&. coinsOut === coins machine .&&. machine1 === machine

prop_Candy_turnOnUnlocked :: Property
prop_Candy_turnOnUnlocked = forAll genUnlockedMachine $ \machine ->
    let ((coinsOut, candiesOut), machine1) = runState (Candy.simulateMachine [Turn]) machine
     in candiesOut
            === candies machine - 1
            .&&. coinsOut
                === coins machine
            .&&. machine1
                === Machine True candiesOut coinsOut

prop_Candy_spendSomeCoins :: Property
prop_Candy_spendSomeCoins = forAll ((,) <$> genLockedMachine <*> choose (1, 1000)) $ \(machine, myCoins) ->
    let wantToSpendAllMyCoins = concat (replicate myCoins [Coin, Turn])
        ((coinsOut, candiesOut), machine1) = runState (Candy.simulateMachine wantToSpendAllMyCoins) machine
        spentCoins = min (candies machine) myCoins
     in candiesOut
            === candies machine - spentCoins
            .&&. coinsOut
                === coins machine + spentCoins
            .&&. machine1
                === Machine True candiesOut coinsOut

prop_Candy_emptyInputs :: Property
prop_Candy_emptyInputs = forAll genMachine $ \machine ->
    let ((coinsOut, candiesOut), machine1) = runState (Candy.simulateMachine []) machine
     in candiesOut === candies machine .&&. coinsOut === coins machine .&&. machine1 === machine

props :: [(String, Property)]
props =
    [ ("RNG.nextInt", prop_RNG_nextInt)
    , ("RNG.nonNegativeInt", prop_RNG_nonNegativeInt)
    , ("RNG.double", prop_RNG_double)
    , ("RNG.intDouble", prop_RNG_intDouble)
    , ("RNG.doubleInt", prop_RNG_doubleInt)
    , ("RNG.double3", prop_RNG_double3)
    , ("RNG.ints", prop_RNG_ints)
    , ("RNG.int", prop_RNG_int)
    , ("RNG.unit", prop_RNG_unit)
    , ("RNG.map", prop_RNG_map)
    , ("RNG.doubleViaMap", prop_RNG_doubleViaMap)
    , ("RNG.map2", prop_RNG_map2)
    , ("RNG.sequence", prop_RNG_sequence)
    , ("RNG.flatMap", prop_RNG_flatMap)
    , ("RNG.mapViaFlatMap", prop_RNG_mapViaFlatMap)
    , ("RNG.map2ViaFlatMap", prop_RNG_map2ViaFlatMap)
    , ("State.unit", prop_State_unit)
    , ("State.map", prop_State_map)
    , ("State.map2", prop_State_map2)
    , ("State.flatMap", prop_State_flatMap)
    , ("State.sequence", prop_State_sequence)
    , ("State.traverse", prop_State_traverse)
    , ("Candy: a machine that's out of candy", prop_Candy_outOfCandy)
    , ("Candy: inserting a coin into a locked machine", prop_Candy_coinIntoLocked)
    , ("Candy: turning the knob on a locked machine", prop_Candy_turnOnLocked)
    , ("Candy: inserting a coin into an unlocked machine", prop_Candy_coinIntoUnlocked)
    , ("Candy: turning the knob on an unlocked machine", prop_Candy_turnOnUnlocked)
    , ("Candy: spend some coins", prop_Candy_spendSomeCoins)
    , ("Candy: empty inputs", prop_Candy_emptyInputs)
    ]
