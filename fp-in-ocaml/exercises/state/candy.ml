type input = Coin | Turn
type machine = { locked : bool; candies : int; coins : int }

(** Exercise 6.11: [State.Monad]を用いて以下のルールを満たすキャンディ販売機の
    振る舞いをシミュレートする関数[simulate_machine]を実装せよ。
    [simulate_machine]は入力リストを受け取って販売機の最終的な キャンディの個数とコインの枚数のペアを返す。

    ルール:
    - 販売機がロックされている([locked = true])とき、ノブを回し([Turn])ても反応しない
    - 販売機がロックされている([locked = true])とき、コインを投入する([Coin])と ロックが外れてコインが1枚増える
    - 販売機がロックされていない([locked = false])とき、ノブを回す([Turn])と ロックが掛かってキャンディが1個減る
    - 販売機がロックされていない([locked = false])とき、コインを投入し([Coin])ても反応しない
    - キャンディが残っていない([candies = 0])とき、コインを投入([Coin])しても ノブを回([Turn])しても反応しない *)
let simulate_machine (_inputs : input list) : (machine, int * int) Monad.t =
  failwith "Not implemented"
