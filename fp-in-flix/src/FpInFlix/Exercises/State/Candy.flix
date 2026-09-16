pub mod FpInFlix.Exercises.State.Candy {
    use FpInFlix.Exercises.State.State

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
        ???
}
