(* exercises のState_monad実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module S = State.Monad

let case n f = Alcotest.test_case n `Quick f

(* カウンター状態の例: 値を持ちつつ整数カウンターをインクリメント。 *)
let inc : (int, int) S.t = fun s -> (s, s + 1)

let test_unit () =
  let v, s = S.run (S.unit 42) 0 in
  Alcotest.(check int) "value" 42 v;
  Alcotest.(check int) "state unchanged" 0 s

let test_map () =
  let v, s = S.run (S.map (fun x -> x + 100) inc) 5 in
  Alcotest.(check int) "value mapped" 105 v;
  Alcotest.(check int) "state advanced" 6 s

let test_map2 () =
  let v, s = S.run (S.map2 ( + ) inc inc) 10 in
  Alcotest.(check int) "value = 10 + 11" 21 v;
  Alcotest.(check int) "state = 12" 12 s

let test_flat_map () =
  let prog = S.flat_map (fun a -> S.map (fun b -> (a, b)) inc) inc in
  let (a, b), s = S.run prog 0 in
  Alcotest.(check int) "a=0" 0 a;
  Alcotest.(check int) "b=1" 1 b;
  Alcotest.(check int) "state=2" 2 s

let test_sequence () =
  let v, s = S.run (S.sequence [ inc; inc; inc ]) 0 in
  Alcotest.(check (list int)) "values" [ 0; 1; 2 ] v;
  Alcotest.(check int) "state=3" 3 s

let test_traverse () =
  let v, s =
    S.run (S.traverse (fun n -> S.map (fun x -> n + x) inc) [ 100; 200; 300 ]) 0
  in
  Alcotest.(check (list int)) "values" [ 100; 201; 302 ] v;
  Alcotest.(check int) "state=3" 3 s

let test_get_set_modify () =
  let v, s = S.run S.get 42 in
  Alcotest.(check int) "get value" 42 v;
  Alcotest.(check int) "get state" 42 s;
  let (), s = S.run (S.set 99) 0 in
  Alcotest.(check int) "set state" 99 s;
  let (), s = S.run (S.modify (fun n -> n + 1)) 10 in
  Alcotest.(check int) "modify state" 11 s

let () =
  Alcotest.run "state.State_monad"
    [
      ("State.unit / map", [ case "unit" test_unit; case "map" test_map ]);
      ("State.map2", [ case "map2" test_map2 ]);
      ("State.flat_map", [ case "flat_map" test_flat_map ]);
      ("State.sequence", [ case "sequence" test_sequence ]);
      ("State.traverse", [ case "traverse" test_traverse ]);
      ("State.get / set / modify", [ case "get/set/modify" test_get_set_modify ]);
    ]
