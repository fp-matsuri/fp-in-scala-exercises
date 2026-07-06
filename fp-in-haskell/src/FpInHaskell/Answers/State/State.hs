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

-- 状態 `s` を持ち回しながら値 `a` を計算する計算を表す型。Scala 版は `opaque type State[S, +A] = S => (A, S)`
-- のように型エイリアスの一種(opaque type)として表現しているが、Haskell では `newtype` で
-- 同じ「実行時のコストなしに元の関数型と見分けられる型」を作れる。フィールド名 `runState` が
-- Scala 版の拡張メソッド `run` に相当する。
newtype State s a = State {runState :: s -> (a, s)}

unit :: a -> State s a
unit a = State (\s -> (a, s))

-- Exercise 6.10: `map`, `map2`, `flatMap` を実装せよ。また、関数 `unit`, `sequence`, `traverse` を実装せよ。
--
-- Prelude の `map` と同じ引数順(関数、State の順)。
map :: (a -> b) -> State s a -> State s b
map f state = flatMap (unit . f) state

map2 :: (a -> b -> c) -> State s a -> State s b -> State s c
map2 f sa sb = flatMap (\a -> map (f a) sb) sa

flatMap :: (a -> State s b) -> State s a -> State s b
flatMap f (State run) = State $ \s ->
    let (a, s1) = run s
     in runState (f a) s1

sequence :: [State s a] -> State s [a]
sequence = foldr (\st acc -> map2 (:) st acc) (unit [])

traverse :: (a -> State s b) -> [a] -> State s [b]
traverse f = foldr (\a acc -> map2 (:) (f a) acc) (unit [])

-- `map`/`flatMap` を Scala 版と同じ意味で `Functor`/`Applicative`/`Monad` に接続しておく。
-- こうすると `modify`(下で定義)や次のファイルの `Candy.simulateMachine` を、Scala 版の
-- for-comprehension とほぼ同じ形の `do` 記法で書ける。Haskell の `do` 記法は `>>=`(bind、
-- ここでは上で実装した `flatMap` と同じもの)へのシンタックスシュガーであり、
-- Scala の for-comprehension が `map`/`flatMap` へのシンタックスシュガーであるのとちょうど対応する。
instance Functor (State s) where
    fmap = map

instance Applicative (State s) where
    pure = unit
    sf <*> sa = map2 ($) sf sa

instance Monad (State s) where
    st >>= f = flatMap f st

-- 現在の状態を値として取り出す。
get :: State s s
get = State (\s -> (s, s))

-- 状態を `s` に置き換える。
set :: s -> State s ()
set s = State (const ((), s))

-- 関数 `f` で状態を更新する。Scala 版は for-comprehension、こちらは `do` 記法で書いており、
-- どちらも `get`/`set` の呼び出しを `flatMap` で繋いでいる点は同じ。
modify :: (s -> s) -> State s ()
modify f = do
    s <- get
    set (f s)
