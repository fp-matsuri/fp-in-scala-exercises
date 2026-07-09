module FpInHaskell.Answers.State.State (
    State (..),
    unit,
    map,
    map2,
    flatMap,
    sequence,
    traverse,
    get,
    set,
    modify,
) where

import Prelude hiding (map, sequence, traverse)

-- Prelude には同名の `map`/`sequence`/`traverse` がすでにあるため、上の
-- `import Prelude hiding (...)` でそれらを読み込み対象から外し、ここでは `State` に対する
-- 同名の演習関数を自前で定義している。

-- 状態 `s` を持ち回しながら値 `a` を計算する計算を表す型。`newtype` を使うことで、
-- 実行時のコストなしに元の関数型 `s -> (a, s)` と見分けられる型を作れる。
-- フィールド名 `runState` で元の関数を取り出して実行できる。
newtype State s a = State {runState :: s -> (a, s)}

unit :: a -> State s a
unit x = State (\st -> (x, st))

-- Exercise 6.10: `map`, `map2`, `flatMap` を実装せよ。また、関数 `unit`, `sequence`, `traverse` を実装せよ。
--
-- Prelude の `map` と同じ引数順(関数、State の順)。
map :: (a -> b) -> State s a -> State s b
map f state = flatMap (unit . f) state

map2 :: (a -> b -> c) -> State s a -> State s b -> State s c
map2 f sa sb = flatMap (\x -> map (f x) sb) sa

flatMap :: (a -> State s b) -> State s a -> State s b
flatMap f (State run) = State (\st0 -> let (x, st1) = run st0 in runState (f x) st1)

sequence :: [State s a] -> State s [a]
sequence = foldr (\st acc -> map2 (:) st acc) (unit [])

traverse :: (a -> State s b) -> [a] -> State s [b]
traverse f = foldr (\x acc -> map2 (:) (f x) acc) (unit [])

-- `map`/`flatMap` を `Functor`/`Applicative`/`Monad` に接続しておく。こうすると `modify`
-- (下で定義)や次のファイルの `Candy.simulateMachine` を `do` 記法で書ける。`do` 記法は
-- `>>=`(bind、ここでは上で実装した `flatMap` と同じもの)へのシンタックスシュガーだ。
instance Functor (State s) where
    fmap = map

instance Applicative (State s) where
    pure = unit

    -- ここでの `$` は括弧を避けるための記法ではなく、「関数を引数に適用する」という演算そのものを
    -- 値として `map2` に渡している。`map2 (\f x -> f x) sf sa` と同じ意味になる。
    sf <*> sa = map2 ($) sf sa

instance Monad (State s) where
    st >>= f = flatMap f st

-- 現在の状態を値として取り出す。
get :: State s s
get = State (\st -> (st, st))

-- 状態を `newState` に置き換える。
set :: s -> State s ()
set newState = State (const ((), newState))

-- 関数 `f` で状態を更新する。`do` 記法の内部では `get`/`set` の呼び出しが `flatMap` で
-- 繋がれている。
modify :: (s -> s) -> State s ()
modify f = do
    st <- get
    set (f st)
