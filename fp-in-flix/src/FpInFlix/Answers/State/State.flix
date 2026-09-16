pub mod FpInFlix.Answers.State.State {
    pub enum State[s, a](s -> (a, s))

    pub def runState(s0: s, sa: State[s, a]): (a, s) =
        let State(f) = sa;
        f(s0)

    // Exercise 6.10: 関数 `map`, `map2`, `flatMap` を実装せよ。
    // また、関数 `unit`, `sequence`, `traverse` を実装せよ。

    pub def map(f: a -> b, sa: State[s, a]): State[s, b] =
        flatMap(f >> unit, sa)

    pub def map2(f: (a, b) -> c, sa: State[s, a], sb: State[s, b]): State[s, c] =
        flatMap(a -> map(b -> f(a, b), sb), sa)

    pub def flatMap(f: a -> State[s, b], sa: State[s, a]): State[s, b] =
        State(s0 ->
            let (a, s1) = runState(s0, sa);
            runState(s1, f(a))
        )

    pub def unit(a: a): State[s, a] =
        State(s -> (a, s))

    pub def sequence(sas: List[State[s, a]]): State[s, List[a]] =
        List.foldRight((sa, acc) -> map2(List.cons, sa, acc), unit(Nil), sas)

    pub def traverse(f: a -> State[s, b], xs: List[a]): State[s, List[b]] =
        List.foldRight((x, acc) -> map2(List.cons, f(x), acc), unit(Nil), xs)

    pub def modify(f: s -> s): State[s, Unit] =
        flatMap(f >> set, get())

    pub def get(): State[s, s] =
        State(s -> (s, s))

    pub def set(s: s): State[s, Unit] =
        State(_ -> ((), s))
}
