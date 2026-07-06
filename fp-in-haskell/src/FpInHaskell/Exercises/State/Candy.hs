module FpInHaskell.Exercises.State.Candy (
    Input (..),
    Machine (..),
    simulateMachine,
) where

import FpInHaskell.Exercises.State.State (State)

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

simulateMachine :: [Input] -> State Machine (Int, Int)
simulateMachine = undefined
