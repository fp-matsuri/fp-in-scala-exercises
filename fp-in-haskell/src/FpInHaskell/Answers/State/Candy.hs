module FpInHaskell.Answers.State.Candy (
    Input (..),
    Machine (..),
    simulateMachine,
) where

import FpInHaskell.Answers.State.State (State, get, modify, traverse)
import Prelude hiding (traverse)

-- State.hs で自作した `traverse`(State モナドを使う版)を使うため、Prelude の `traverse`
-- (Traversable/Applicative に対する汎用版)を読み込み対象から外している。
data Input = Coin | Turn
    deriving (Show, Eq)

data Machine = Machine {locked :: Bool, candies :: Int, coins :: Int}
    deriving (Show, Eq)

-- Exercise 6.11: State を用いて以下のルールを満たすキャンディ販売機の振る舞いをシミュレートする
-- 関数 `simulateMachine` を実装せよ。`simulateMachine` は入力リストを受け取って販売機の最終的な
-- キャンディの個数とコインの枚数のペアを返す。
--
-- ルール:
--   - 販売機がロックされている(locked = True)とき、ノブを回し(Turn)ても販売機は反応しない
--   - 販売機がロックされている(locked = True)とき、コインを投入する(Coin)と
--     販売機のロックが外れてコインが1枚増える
--   - 販売機がロックされていない(locked = False)とき、ノブを回す(Turn)と
--     販売機のロックが掛かってキャンディが1個減る
--   - 販売機がロックされていない(locked = False)とき、コインを投入し(Coin)ても販売機は反応しない
--   - 販売機にキャンディが残っていない(candies = 0)とき、コインを投入し(Coin)ても
--     ノブを回し(Turn)ても販売機は反応しない
--
-- State.hs で用意した Monad インスタンスのおかげで do 記法で書ける。
--
-- `\i -> modify (update i)` は `update` の結果を `modify` に流す関数なので、
-- 関数合成 `modify . update :: Input -> State Machine ()` と等しい。
simulateMachine :: [Input] -> State Machine (Int, Int)
simulateMachine inputs = do
    _ <- traverse (modify . update) inputs
    s <- get
    return (coins s, candies s)

update :: Input -> Machine -> Machine
update _ m@(Machine _ 0 _) = m
update Coin m@(Machine False _ _) = m
update Turn m@(Machine True _ _) = m
update Coin (Machine True cnd cns) = Machine False cnd (cns + 1)
update Turn (Machine False cnd cns) = Machine True (cnd - 1) cns
