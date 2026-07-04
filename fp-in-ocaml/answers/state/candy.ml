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
let simulate_machine (inputs : input list) : (machine, int * int) Monad.t =
  let open Monad in
  let open Syntax in
  let* _ =
    inputs
    |> traverse @@ fun i ->
       modify @@ fun m ->
       match (i, m) with
       (* ルール上は最後に記載されているが、最初にマッチして何も起きないことを記述。 *)
       | _, { candies = 0; _ } -> m
       (* locked = true の場合を見る。
          必要ないパラメータは[_]でまとめて捨てることができる。
        *)
       | Turn, { locked = true; _ } -> m
       | Coin, { locked = true; _ } ->
           (* record のアップデートには [with] が使える。
              @see <https://ocaml.org/manual/5.4/coreexamples.html#s:tut-recvariants> Records and variants
            *)
           { m with locked = false; coins = m.coins + 1 }
       (* 以降は locked = false
          実装上は[m]のパターンを記述せずとも問題ないが、今回はルールをそのまま書いておく。
        *)
       | Turn, { locked = false; _ } ->
           { m with locked = true; candies = m.candies - 1 }
       | Coin, { locked = false; _ } -> m
  in
  let+ m = get in
  (m.coins, m.candies)
