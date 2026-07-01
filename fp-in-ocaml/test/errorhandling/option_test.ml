(* exercises のOption実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module O = Errorhandling.Option

(** Alcotest用の[Option.t]testable。 標準の[option]ではなく独自型なので、対応する整形関数を渡す。 *)
let opt_pp pp_a fmt = function
  | O.None -> Format.fprintf fmt "None"
  | O.Some a -> Format.fprintf fmt "Some %a" pp_a a

let opt_eq eq a b =
  match (a, b) with
  | O.None, O.None -> true
  | O.Some x, O.Some y -> eq x y
  | _ -> false

let opt_testable t = Alcotest.testable (opt_pp (Alcotest.pp t)) (opt_eq ( = ))
let opt_int = opt_testable Alcotest.int
let opt_string = opt_testable Alcotest.string
let opt_int_list = opt_testable (Alcotest.list Alcotest.int)
let case n f = Alcotest.test_case n `Quick f

let test_map () =
  Alcotest.(check opt_string) "None" O.None (O.map string_of_int O.None);
  Alcotest.(check opt_string)
    "Some 42" (O.Some "42")
    (O.map string_of_int (O.Some 42))

let test_get_or_else () =
  Alcotest.(check int) "None" 1 (O.get_or_else 1 O.None);
  Alcotest.(check int) "Some 5" 5 (O.get_or_else 1 (O.Some 5))

let test_flat_map () =
  let f n = if n mod 2 = 0 then O.Some (n / 2) else O.None in
  Alcotest.(check opt_int) "None" O.None (O.flat_map f O.None);
  Alcotest.(check opt_int)
    "Some 4 -> Some 2" (O.Some 2) (O.flat_map f (O.Some 4));
  Alcotest.(check opt_int) "Some 5 -> None" O.None (O.flat_map f (O.Some 5))

let test_or_else () =
  let alt = O.Some 1 in
  Alcotest.(check opt_int) "None" alt (O.or_else alt O.None);
  Alcotest.(check opt_int) "Some 7" (O.Some 7) (O.or_else alt (O.Some 7))

let test_filter () =
  Alcotest.(check opt_int) "None" O.None (O.filter (fun n -> n = 42) O.None);
  Alcotest.(check opt_int)
    "Some 5 keeping" (O.Some 5)
    (O.filter (fun a -> a = 5) (O.Some 5));
  Alcotest.(check opt_int)
    "Some 5 dropping" O.None
    (O.filter (fun a -> a = 6) (O.Some 5))

let test_mean () =
  let opt_float = opt_testable (Alcotest.float 1e-9) in
  Alcotest.(check opt_float) "empty" O.None (O.mean []);
  Alcotest.(check opt_float)
    "[1;2;3;4;5]" (O.Some 3.0)
    (O.mean [ 1.0; 2.0; 3.0; 4.0; 5.0 ]);
  Alcotest.(check opt_float) "single" (O.Some 7.0) (O.mean [ 7.0 ])

let test_variance () =
  (* 浮動小数点の比較は近似比較で行う *)
  let close a b = abs_float (a -. b) < 1e-9 in
  Alcotest.(check bool) "empty" true (opt_eq close (O.variance []) O.None);
  Alcotest.(check bool)
    "constant" true
    (opt_eq close (O.variance [ 5.0; 5.0; 5.0 ]) (O.Some 0.0));
  Alcotest.(check bool)
    "[1;2;3;4;5]" true
    (opt_eq close (O.variance [ 1.0; 2.0; 3.0; 4.0; 5.0 ]) (O.Some 2.0))

let test_map2 () =
  Alcotest.(check opt_int)
    "Some + Some" (O.Some 5)
    (O.map2 ( + ) (O.Some 2) (O.Some 3));
  Alcotest.(check opt_int) "None + Some" O.None (O.map2 ( + ) O.None (O.Some 3));
  Alcotest.(check opt_int) "Some + None" O.None (O.map2 ( + ) (O.Some 2) O.None);
  Alcotest.(check opt_int) "None + None" O.None (O.map2 ( + ) O.None O.None)

let test_sequence () =
  Alcotest.(check opt_int_list)
    "all Some"
    (O.Some [ 1; 2; 3 ])
    (O.sequence [ O.Some 1; O.Some 2; O.Some 3 ]);
  Alcotest.(check opt_int_list)
    "has None" O.None
    (O.sequence [ O.Some 1; O.None; O.Some 3 ]);
  Alcotest.(check opt_int_list) "empty" (O.Some []) (O.sequence [])

let str_to_opt_int s =
  match int_of_string_opt s with Some n -> O.Some n | None -> O.None

let test_traverse () =
  Alcotest.(check opt_int_list)
    "all parse"
    (O.Some [ 1; 2; 3 ])
    (O.traverse str_to_opt_int [ "1"; "2"; "3" ]);
  Alcotest.(check opt_int_list)
    "has failure" O.None
    (O.traverse str_to_opt_int [ "1"; "one"; "3" ]);
  Alcotest.(check opt_int_list)
    "empty" (O.Some [])
    (O.traverse str_to_opt_int [])

let () =
  Alcotest.run "errorhandling.Option"
    [
      ( "Option.map / get_or_else / flat_map / or_else / filter",
        [
          case "map" test_map;
          case "get_or_else" test_get_or_else;
          case "flat_map" test_flat_map;
          case "or_else" test_or_else;
          case "filter" test_filter;
        ] );
      ("Option.mean", [ case "mean" test_mean ]);
      ("Option.variance", [ case "variance" test_variance ]);
      ("Option.map2", [ case "map2" test_map2 ]);
      ("Option.sequence", [ case "sequence" test_sequence ]);
      ("Option.traverse", [ case "traverse" test_traverse ]);
    ]
