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

    // Exercise 6.11: Stateを用いて以下のルールを満たすキャンディ販売機の振る舞いをシミュレートする関数 `simulateMachine` を実装せよ。
    // `simulateMachine` は入力リストを受け取って販売機の最終的なコインの枚数とキャンディの個数のペアを返す。
    // ルール:
    //   - 販売機がロックされている(`locked = true`)とき、ノブを回し(Input.Turn)ても販売機は反応しない
    //   - 販売機がロックされている(`locked = true`)とき、コインを投入する(Input.Coin)と販売機のロックが外れてコインが1枚増える
    //   - 販売機がロックされていない(`locked = false`)とき、ノブを回す(Input.Turn)と販売機のロックが掛かってキャンディが1個減る
    //   - 販売機がロックされていない(`locked = false`)とき、コインを投入し(Input.Coin)ても販売機は反応しない
    //   - 販売機にキャンディが残っていない(`candies = 0`)とき、コインを投入し(Input.Coin)てもノブを回し(Input.Turn)ても販売機は反応しない

    pub enum Input {
        case Coin
        case Turn
    }

    pub type alias Machine = {
        locked = Bool,
        candies = Int32,
        coins = Int32
    }

    mod Candy {
        use FpInFlix.Answers.State.State.{Input, Machine, State}

        pub def simulateMachine(inputs: List[Input]): State[Machine, (Int32, Int32)] =
            inputs
                |> State.traverse(update >> State.modify)
                |> State.flatMap(_ ->
                    State.map(s ->
                        (s#coins, s#candies),
                        State.get()
                    )
                )

        def update(i: Input, m: Machine): Machine =
            match (i, m) {
                case (_, {candies = 0 | _}) => m
                case (Input.Coin, {locked = false | _}) => m
                case (Input.Turn, {locked = true | _}) => m
                case (Input.Coin, {locked = true, candies, coins}) =>
                    {locked = false, candies = candies, coins = coins + 1}
                case (Input.Turn, {locked = false, candies, coins}) =>
                    {locked = true, candies = candies - 1, coins = coins}
            }
    }
}
