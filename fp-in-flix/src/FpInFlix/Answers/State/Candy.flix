pub mod FpInFlix.Answers.State.Candy {
    use FpInFlix.Answers.State.State

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
