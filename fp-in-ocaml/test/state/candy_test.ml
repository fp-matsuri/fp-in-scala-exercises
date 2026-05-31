(* exercises のCandy実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module C = State.Candy
module S = State.Monad

let case n f = Alcotest.test_case n `Quick f

let test_book_example () =
  (* 書籍の例: 4種類のキャンディが入った機械に対し、4枚のコイン投入と4回のノブ回し *)
  let inputs =
    [ C.Coin; C.Turn; C.Coin; C.Turn; C.Coin; C.Turn; C.Coin; C.Turn ]
  in
  let initial = { C.locked = true; candies = 5; coins = 10 } in
  let (coins, candies), _ = S.run (C.simulate_machine inputs) initial in
  Alcotest.(check int) "coins" 14 coins;
  Alcotest.(check int) "candies" 1 candies

let test_no_inputs () =
  let initial = { C.locked = true; candies = 5; coins = 10 } in
  let (coins, candies), m = S.run (C.simulate_machine []) initial in
  Alcotest.(check int) "coins unchanged" 10 coins;
  Alcotest.(check int) "candies unchanged" 5 candies;
  Alcotest.(check bool) "still locked" true m.locked

let test_no_candies () =
  let initial = { C.locked = true; candies = 0; coins = 10 } in
  let (coins, candies), _ =
    S.run (C.simulate_machine [ C.Coin; C.Turn ]) initial
  in
  Alcotest.(check int) "coins unchanged when no candies" 10 coins;
  Alcotest.(check int) "candies still 0" 0 candies

let test_turn_when_locked () =
  let initial = { C.locked = true; candies = 5; coins = 10 } in
  let (coins, candies), _ = S.run (C.simulate_machine [ C.Turn ]) initial in
  Alcotest.(check int) "coins unchanged on turn when locked" 10 coins;
  Alcotest.(check int) "candies unchanged on turn when locked" 5 candies

let test_coin_when_unlocked () =
  let initial = { C.locked = false; candies = 5; coins = 10 } in
  let (coins, candies), _ = S.run (C.simulate_machine [ C.Coin ]) initial in
  Alcotest.(check int) "coins unchanged on coin when unlocked" 10 coins;
  Alcotest.(check int) "candies unchanged on coin when unlocked" 5 candies

let () =
  Alcotest.run "state.Candy"
    [
      ( "Candy.simulate_machine",
        [
          case "book example" test_book_example;
          case "no inputs" test_no_inputs;
          case "no candies" test_no_candies;
          case "turn when locked is no-op" test_turn_when_locked;
          case "coin when unlocked is no-op" test_coin_when_unlocked;
        ] );
    ]
