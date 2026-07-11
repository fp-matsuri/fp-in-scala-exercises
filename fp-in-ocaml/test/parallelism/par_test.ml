(* exercises のPar実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module P = Parallelism.Par

(* fork の入れ子がデッドロックしない程度に十分な数のワーカーを用意する。
   固定サイズプールと fork の組み合わせによるデッドロックは本章の主題の1つ
   (exercises/parallelism/par.ml の [fork] のコメントを参照)。 *)
let with_pool f =
  let es = P.Executor.make 16 in
  Fun.protect ~finally:(fun () -> P.Executor.shutdown es) (fun () -> f es)

let case n f = Alcotest.test_case n `Quick f

let test_unit_run () =
  with_pool @@ fun es -> Alcotest.(check int) "unit 1" 1 (P.run es (P.unit 1))

let test_map2 () =
  with_pool @@ fun es ->
  Alcotest.(check int) "1 + 2" 3 (P.run es (P.map2 ( + ) (P.unit 1) (P.unit 2)))

let test_fork () =
  with_pool @@ fun es ->
  Alcotest.(check int) "forked" 42 (P.run es (P.fork (lazy (P.unit 42))))

let test_lazy_unit_is_lazy () =
  with_pool @@ fun es ->
  let evaluated = ref false in
  let p =
    P.lazy_unit
      (lazy
        (evaluated := true;
         42))
  in
  Alcotest.(check bool) "not evaluated before run" false !evaluated;
  Alcotest.(check int) "value" 42 (P.run es p);
  Alcotest.(check bool) "evaluated after run" true !evaluated

let test_async_f () =
  with_pool @@ fun es ->
  Alcotest.(check int) "succ" 42 (P.run es (P.async_f succ 41))

let test_map () =
  with_pool @@ fun es ->
  Alcotest.(check string)
    "map string_of_int" "42"
    (P.run es (P.map string_of_int (P.unit 42)))

let test_sort_par () =
  with_pool @@ fun es ->
  Alcotest.(check (list int))
    "sorted" [ 1; 2; 3 ]
    (P.run es (P.sort_par (P.unit [ 3; 1; 2 ])))

let test_sequence_right () =
  with_pool @@ fun es ->
  Alcotest.(check (list int))
    "sequence_right" [ 1; 2; 3 ]
    (P.run es (P.sequence_right [ P.unit 1; P.unit 2; P.unit 3 ]))

let test_sequence_balanced () =
  with_pool @@ fun es ->
  Alcotest.(check (array int))
    "sequence_balanced" [| 1; 2; 3; 4; 5 |]
    (P.run es (P.sequence_balanced (Array.init 5 (fun i -> P.unit (succ i)))));
  Alcotest.(check (array int))
    "empty" [||]
    (P.run es (P.sequence_balanced [||]))

let test_sequence () =
  with_pool @@ fun es ->
  Alcotest.(check (list int))
    "sequence" [ 1; 2; 3 ]
    (P.run es (P.sequence [ P.unit 1; P.unit 2; P.unit 3 ]));
  Alcotest.(check (list int)) "empty" [] (P.run es (P.sequence []))

let test_par_map () =
  with_pool @@ fun es ->
  Alcotest.(check (list int))
    "squares" [ 1; 4; 9; 16 ]
    (P.run es (P.par_map (fun x -> x * x) [ 1; 2; 3; 4 ]))

let test_par_filter () =
  with_pool @@ fun es ->
  Alcotest.(check (list int))
    "evens" [ 2; 4; 6; 8; 10 ]
    (P.run es
       (P.par_filter (fun x -> x mod 2 = 0) [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ]))

let test_equal () =
  with_pool @@ fun es ->
  Alcotest.(check bool)
    "map succ = unit 2" true
    (P.equal es (P.map succ (P.unit 1)) (P.unit 2))

let test_choice () =
  with_pool @@ fun es ->
  Alcotest.(check string)
    "true" "t"
    (P.run es (P.choice (P.unit true) (P.unit "t") (P.unit "f")));
  Alcotest.(check string)
    "false" "f"
    (P.run es (P.choice (P.unit false) (P.unit "t") (P.unit "f")))

let choices = [ P.unit "a"; P.unit "b"; P.unit "c" ]

let test_choice_n () =
  with_pool @@ fun es ->
  Alcotest.(check string)
    "index 1" "b"
    (P.run es (P.choice_n (P.unit 1) choices))

let test_choice_via_choice_n () =
  with_pool @@ fun es ->
  Alcotest.(check string)
    "true" "t"
    (P.run es (P.choice_via_choice_n (P.unit true) (P.unit "t") (P.unit "f")));
  Alcotest.(check string)
    "false" "f"
    (P.run es (P.choice_via_choice_n (P.unit false) (P.unit "t") (P.unit "f")))

let test_choice_map () =
  with_pool @@ fun es ->
  let m = [ ("a", P.unit 1); ("b", P.unit 2) ] in
  Alcotest.(check int) "key b" 2 (P.run es (P.choice_map (P.unit "b") m))

let test_chooser () =
  with_pool @@ fun es ->
  Alcotest.(check int)
    "x * 10" 20
    (P.run es (P.chooser (fun x -> P.unit (x * 10)) (P.unit 2)))

let test_choice_via_chooser () =
  with_pool @@ fun es ->
  Alcotest.(check string)
    "true" "t"
    (P.run es (P.choice_via_chooser (P.unit true) (P.unit "t") (P.unit "f")));
  Alcotest.(check string)
    "false" "f"
    (P.run es (P.choice_via_chooser (P.unit false) (P.unit "t") (P.unit "f")))

let test_choice_n_via_chooser () =
  with_pool @@ fun es ->
  Alcotest.(check string)
    "index 2" "c"
    (P.run es (P.choice_n_via_chooser (P.unit 2) choices))

let test_flat_map () =
  with_pool @@ fun es ->
  Alcotest.(check int)
    "flat_map" 42
    (P.run es (P.flat_map (fun x -> P.lazy_unit (lazy (x * 2))) (P.unit 21)))

let test_join () =
  with_pool @@ fun es ->
  Alcotest.(check int) "join" 42 (P.run es (P.join (P.unit (P.unit 42))))

let test_join_via_flat_map () =
  with_pool @@ fun es ->
  Alcotest.(check int)
    "join_via_flat_map" 42
    (P.run es (P.join_via_flat_map (P.unit (P.unit 42))))

let test_flat_map_via_join () =
  with_pool @@ fun es ->
  Alcotest.(check int)
    "flat_map_via_join" 42
    (P.run es (P.flat_map_via_join (fun x -> P.unit (x * 2)) (P.unit 21)))

let test_examples_sum () =
  Alcotest.(check int) "sum" 15 (P.Examples.sum [| 1; 2; 3; 4; 5 |]);
  Alcotest.(check int) "empty" 0 (P.Examples.sum [||])

let () =
  Alcotest.run "parallelism.Par"
    [
      ( "Par.basic",
        [
          case "unit/run" test_unit_run;
          case "map2" test_map2;
          case "fork" test_fork;
          case "lazy_unit is lazy" test_lazy_unit_is_lazy;
          case "map" test_map;
          case "sort_par" test_sort_par;
          case "equal" test_equal;
          case "choice" test_choice;
        ] );
      ("Par.async_f", [ case "async_f" test_async_f ]);
      ( "Par.sequence",
        [
          case "sequence_right" test_sequence_right;
          case "sequence_balanced" test_sequence_balanced;
          case "sequence" test_sequence;
          case "par_map" test_par_map;
        ] );
      ("Par.par_filter", [ case "par_filter" test_par_filter ]);
      ( "Par.choice_n",
        [
          case "choice_n" test_choice_n;
          case "choice_via_choice_n" test_choice_via_choice_n;
        ] );
      ("Par.choice_map", [ case "choice_map" test_choice_map ]);
      ( "Par.chooser",
        [
          case "chooser" test_chooser;
          case "choice_via_chooser" test_choice_via_chooser;
          case "choice_n_via_chooser" test_choice_n_via_chooser;
          case "flat_map" test_flat_map;
        ] );
      ( "Par.join",
        [
          case "join" test_join;
          case "join_via_flat_map" test_join_via_flat_map;
          case "flat_map_via_join" test_flat_map_via_join;
        ] );
      ("Par.examples", [ case "sum" test_examples_sum ]);
    ]
