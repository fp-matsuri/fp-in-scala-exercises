module ErrorHandlingSpec (
    props,
) where

import FpInHaskell.Exercises.ErrorHandling.Either (Either (Left, Right))
import qualified FpInHaskell.Exercises.ErrorHandling.Either as Either
import FpInHaskell.Exercises.ErrorHandling.Option (Option (None, Some))
import qualified FpInHaskell.Exercises.ErrorHandling.Option as Option
import FpInHaskell.Test.Common
import Test.QuickCheck hiding (Some)
import Prelude hiding (Either (..))

-- ch3 の DataStructuresSpec と同じ理由(演習対象のモジュールが Prelude と同名の関数を大量に
-- エクスポートするため)で、演習対象のモジュールだけを修飾 import する。

prop_Option_map :: Property
prop_Option_map = forAll genIntOption $ \o -> case o of
    None -> Option.map show o === None
    Some n -> Option.map show o === Some (show n)

prop_Option_getOrElse :: Property
prop_Option_getOrElse = forAll genIntOption $ \o -> case o of
    None -> Option.getOrElse 1 o === 1
    Some n -> Option.getOrElse 1 o === n

prop_Option_flatMap :: Property
prop_Option_flatMap = forAll genIntOption $ \o -> case o of
    None -> Option.flatMap (Some . show) o === None
    Some n -> Option.flatMap (Some . show) o === Some (show n)

prop_Option_orElse :: Property
prop_Option_orElse = forAll genIntOption $ \o -> case o of
    None -> Option.orElse fallback o === fallback
    _ -> Option.orElse fallback o === o
  where
    fallback = Some 1

prop_Option_filter :: Property
prop_Option_filter = forAll genIntOption $ \o -> case o of
    None -> Option.filter (== 42) o === None
    Some n ->
        Option.filter (== n) o === Some n
            .&&. Option.filter (== n + 1) o === None

prop_Option_mean :: Property
prop_Option_mean = forAll (listOf arbitrary) $ \xs ->
    Option.mean xs === if null xs then None else Some (sum xs / fromIntegral (length xs))

prop_Option_variance :: Property
prop_Option_variance = forAll (listOf arbitrary) $ \xs ->
    Option.variance xs === expected xs
  where
    expected [] = None
    expected ys =
        let m = sum ys / fromIntegral (length ys)
            deviations = map (\x -> (x - m) ** 2) ys
         in Some (sum deviations / fromIntegral (length deviations))

prop_Option_map2 :: Property
prop_Option_map2 = forAll ((,) <$> genIntOption <*> genIntOption) $ \(oa, ob) ->
    case (oa, ob) of
        (Some a, Some b) -> Option.map2 (+) oa ob === Some (a + b)
        _ -> Option.map2 (+) oa ob === None

prop_Option_sequence :: Property
prop_Option_sequence = forAll (listOf genIntOption) $ \os ->
    Option.sequence os === expected os
  where
    expected xs
        | any isNone xs = None
        | otherwise = Some (map unwrap xs)
    isNone None = True
    isNone (Some _) = False
    unwrap (Some x) = x
    unwrap None = error "unreachable: filtered out above"

prop_Option_traverse :: Property
prop_Option_traverse = forAll (listOf genNumericOrInvalidString) $ \xs ->
    Option.traverse parseIntOpt xs === expected xs
  where
    genNumericOrInvalidString = oneof [pure "one", show <$> (arbitrary :: Gen Int)]
    parseIntOpt s = case reads s of
        [(n, "")] -> Some n
        _ -> None
    expected xs
        | "one" `elem` xs = None
        | otherwise = Some (map (\s -> read s :: Int) xs)

newtype Name = Name String deriving (Show, Eq)
newtype Age = Age Int deriving (Show, Eq)
data Person = Person Name Age deriving (Show, Eq)

makeName :: String -> Either String Name
makeName "" = Left "Name is empty."
makeName n = Right (Name n)

makeName2 :: String -> Either [String] Name
makeName2 "" = Left ["Name is empty."]
makeName2 n = Right (Name n)

makeAge :: Int -> Either String Age
makeAge n
    | n < 0 = Left "Age is out of range."
    | otherwise = Right (Age n)

makeAge2 :: Int -> Either [String] Age
makeAge2 n
    | n < 0 = Left ["Age is out of range."]
    | otherwise = Right (Age n)

genName :: Gen String
genName = oneof [pure "", listOf1 (choose ('a', 'z'))]

genPosAge :: Gen Int
genPosAge = choose (1, 50)

genAge :: Gen Int
genAge = choose (-50, 50)

genAgesList :: Gen [Int]
genAgesList = oneof [sizedListOf genPosAge, sizedListOf genAge]
  where
    sizedListOf g = do
        n <- choose (0, 10)
        vectorOf n g

prop_Either_map :: Property
prop_Either_map = forAll genStringIntEither $ \e -> case e of
    Left _ -> Either.map (`div` 2) e === e
    Right n -> Either.map (`div` 2) e === Right (n `div` 2)

prop_Either_flatMap :: Property
prop_Either_flatMap = forAll genStringIntEither $ \e ->
    case e of
        Left _ -> Either.flatMap f e === e
        Right n
            | odd n -> Either.flatMap f e === Left "An odd number"
            | otherwise -> Either.flatMap f e === Right (n `div` 2)
  where
    f n = if even n then Right (n `div` 2) else Left "An odd number"

prop_Either_orElse :: Property
prop_Either_orElse = forAll ((,) <$> genStringIntEither <*> genStringIntEither) $ \(self, fallback) ->
    case self of
        Left _ -> Either.orElse fallback self === fallback
        Right _ -> Either.orElse fallback self === self

prop_Either_map2 :: Property
prop_Either_map2 = forAll ((,) <$> genName <*> genAge) $ \(name, age) ->
    Either.map2 Person (makeName name) (makeAge age) === expected name age
  where
    expected "" _ = Left "Name is empty."
    expected _ age' | age' < 0 = Left "Age is out of range."
    expected name age' = Right (Person (Name name) (Age age'))

prop_Either_traverse :: Property
prop_Either_traverse = forAll genAgesList $ \ages ->
    Either.traverse makeAge ages === expected ages
  where
    expected ages
        | any (< 0) ages = Left "Age is out of range."
        | otherwise = Right (map Age ages)

prop_Either_sequence :: Property
prop_Either_sequence = forAll genAgesList $ \ages ->
    Either.sequence (map makeAge ages) === expected ages
  where
    expected ages
        | any (< 0) ages = Left "Age is out of range."
        | otherwise = Right (map Age ages)

prop_Either_map2All :: Property
prop_Either_map2All = forAll ((,) <$> genName <*> genAge) $ \(name, age) ->
    Either.map2All Person (makeName2 name) (makeAge2 age) === expected name age
  where
    expected "" age' | age' < 0 = Left ["Name is empty.", "Age is out of range."]
    expected "" _ = Left ["Name is empty."]
    expected _ age' | age' < 0 = Left ["Age is out of range."]
    expected name age' = Right (Person (Name name) (Age age'))

prop_Either_traverseAll :: Property
prop_Either_traverseAll = forAll genAgesList $ \ages ->
    Either.traverseAll makeAge2 ages === expected ages
  where
    expected ages =
        let negCount = length (filter (< 0) ages)
         in if negCount > 0
                then Left (replicate negCount "Age is out of range.")
                else Right (map Age ages)

prop_Either_sequenceAll :: Property
prop_Either_sequenceAll = forAll genAgesList $ \ages ->
    Either.sequenceAll (map makeAge2 ages) === expected ages
  where
    expected ages =
        let negCount = length (filter (< 0) ages)
         in if negCount > 0
                then Left (replicate negCount "Age is out of range.")
                else Right (map Age ages)

props :: [(String, Property)]
props =
    [ ("Option.map", prop_Option_map)
    , ("Option.getOrElse", prop_Option_getOrElse)
    , ("Option.flatMap", prop_Option_flatMap)
    , ("Option.orElse", prop_Option_orElse)
    , ("Option.filter", prop_Option_filter)
    , ("Option.mean", prop_Option_mean)
    , ("Option.variance", prop_Option_variance)
    , ("Option.map2", prop_Option_map2)
    , ("Option.sequence", prop_Option_sequence)
    , ("Option.traverse", prop_Option_traverse)
    , ("Either.map", prop_Either_map)
    , ("Either.flatMap", prop_Either_flatMap)
    , ("Either.orElse", prop_Either_orElse)
    , ("Either.map2", prop_Either_map2)
    , ("Either.traverse", prop_Either_traverse)
    , ("Either.sequence", prop_Either_sequence)
    , ("Either.map2All", prop_Either_map2All)
    , ("Either.traverseAll", prop_Either_traverseAll)
    , ("Either.sequenceAll", prop_Either_sequenceAll)
    ]
