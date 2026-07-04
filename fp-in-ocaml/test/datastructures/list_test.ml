(* exercises のList実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module L = Datastructures.List

(** [L.t]をstdlibの[list]に変換する補助。 *)
let rec to_list = function L.Nil -> [] | L.Cons (h, t) -> h :: to_list t

let case n f = Alcotest.test_case n `Quick f
let int_list = Alcotest.(list int)
let float_list = Alcotest.(list (float 1e-9))
let string_list = Alcotest.(list string)

let test_result () =
  (* Exercise 3.1 の答えは 3。
     最初のパターン [Cons (x, Cons (2, Cons (4, _)))] には2番目が4でないのでマッチせず、
     次に [Cons (x, Cons (y, Cons (3, Cons (4, _))))] にマッチする(x=1, y=2, 残=Cons(3, Cons(4, _)))。 *)
  Alcotest.(check int) "result" 3 L.result

let test_tail () =
  Alcotest.(check int_list)
    "tail" [ 2; 3 ]
    (to_list (L.tail (L.make [ 1; 2; 3 ])))

let test_set_head () =
  Alcotest.(check int_list)
    "set_head" [ 99; 2; 3 ]
    (to_list (L.set_head 99 (L.make [ 1; 2; 3 ])))

let test_drop () =
  Alcotest.(check int_list)
    "drop 2" [ 3; 4 ]
    (to_list (L.drop 2 (L.make [ 1; 2; 3; 4 ])));
  Alcotest.(check int_list)
    "drop 0" [ 1; 2 ]
    (to_list (L.drop 0 (L.make [ 1; 2 ])));
  Alcotest.(check int_list)
    "drop overflow" []
    (to_list (L.drop 10 (L.make [ 1; 2 ])))

let test_drop_while () =
  Alcotest.(check int_list)
    "drop_while < 3" [ 3; 4 ]
    (to_list (L.drop_while (fun x -> x < 3) (L.make [ 1; 2; 3; 4 ])))

let test_init () =
  Alcotest.(check int_list)
    "init" [ 1; 2; 3 ]
    (to_list (L.init (L.make [ 1; 2; 3; 4 ])))

let test_length () =
  Alcotest.(check int) "length" 5 (L.length (L.make [ 1; 2; 3; 4; 5 ]));
  Alcotest.(check int) "length empty" 0 (L.length L.Nil)

let test_fold_left () =
  Alcotest.(check int)
    "sum via fold_left" 15
    (L.fold_left 0 ( + ) (L.make [ 1; 2; 3; 4; 5 ]));
  Alcotest.(check string)
    "reverse via fold_left" "edcba"
    (L.fold_left "" (fun acc c -> c ^ acc) (L.make [ "a"; "b"; "c"; "d"; "e" ]))

let test_via_fold_left () =
  Alcotest.(check int)
    "sum_via_fold_left" 15
    (L.sum_via_fold_left (L.make [ 1; 2; 3; 4; 5 ]));
  Alcotest.(check (float 1e-9))
    "product_via_fold_left" 24.0
    (L.product_via_fold_left (L.make [ 1.0; 2.0; 3.0; 4.0 ]));
  Alcotest.(check int)
    "length_via_fold_left" 4
    (L.length_via_fold_left (L.make [ 1; 2; 3; 4 ]))

let test_reverse () =
  Alcotest.(check int_list)
    "reverse [1..5]" [ 5; 4; 3; 2; 1 ]
    (to_list (L.reverse (L.make [ 1; 2; 3; 4; 5 ])))

let test_append_via_fold_right () =
  Alcotest.(check int_list)
    "[1;2] ++ [3;4]" [ 1; 2; 3; 4 ]
    (to_list (L.append_via_fold_right (L.make [ 1; 2 ]) (L.make [ 3; 4 ])))

let test_concat () =
  Alcotest.(check int_list)
    "concat [[1;2];[3];[4;5]]" [ 1; 2; 3; 4; 5 ]
    (to_list
       (L.concat (L.make [ L.make [ 1; 2 ]; L.make [ 3 ]; L.make [ 4; 5 ] ])))

let test_increment_each () =
  Alcotest.(check int_list)
    "increment_each [1;2;3]" [ 2; 3; 4 ]
    (to_list (L.increment_each (L.make [ 1; 2; 3 ])))

let test_double_to_string () =
  let result = to_list (L.double_to_string (L.make [ 1.0; 2.5 ])) in
  Alcotest.(check int) "length" 2 (List.length result)

let test_map () =
  Alcotest.(check int_list)
    "map (+1)" [ 2; 3; 4 ]
    (to_list (L.map (L.make [ 1; 2; 3 ]) (fun x -> x + 1)))

let test_filter () =
  Alcotest.(check int_list)
    "filter even" [ 2; 4 ]
    (to_list (L.filter (L.make [ 1; 2; 3; 4 ]) (fun x -> x mod 2 = 0)))

let test_flat_map () =
  Alcotest.(check int_list)
    "flat_map dup" [ 1; 1; 2; 2; 3; 3 ]
    (to_list (L.flat_map (L.make [ 1; 2; 3 ]) (fun x -> L.make [ x; x ])))

let test_filter_via_flat_map () =
  Alcotest.(check int_list)
    "filter_via_flat_map even" [ 2; 4 ]
    (to_list
       (L.filter_via_flat_map (L.make [ 1; 2; 3; 4 ]) (fun x -> x mod 2 = 0)))

let test_add_pairwise () =
  Alcotest.(check int_list)
    "add_pairwise" [ 5; 7; 9 ]
    (to_list (L.add_pairwise (L.make [ 1; 2; 3 ]) (L.make [ 4; 5; 6 ])));
  Alcotest.(check int_list)
    "different lengths" [ 5; 7 ]
    (to_list (L.add_pairwise (L.make [ 1; 2 ]) (L.make [ 4; 5; 6 ])))

let test_zip_with () =
  Alcotest.(check string_list)
    "zip_with" [ "1a"; "2b" ]
    (to_list
       (L.zip_with
          (L.make [ 1; 2; 3 ])
          (L.make [ "a"; "b" ])
          (fun n c -> string_of_int n ^ c)))

let test_has_subsequence () =
  let l = L.make [ 1; 2; 3; 4 ] in
  Alcotest.(check bool) "[1;2]" true (L.has_subsequence l (L.make [ 1; 2 ]));
  Alcotest.(check bool) "[2;3]" true (L.has_subsequence l (L.make [ 2; 3 ]));
  Alcotest.(check bool) "[4]" true (L.has_subsequence l (L.make [ 4 ]));
  Alcotest.(check bool) "[1;4]" false (L.has_subsequence l (L.make [ 1; 4 ]));
  Alcotest.(check bool) "empty" true (L.has_subsequence l L.Nil);
  Alcotest.(check bool)
    "longer than" false
    (L.has_subsequence l (L.make [ 1; 2; 3; 4; 5 ]))

let _ = float_list

let () =
  Alcotest.run "datastructures.List"
    [
      ("List.result", [ case "Exercise 3.1" test_result ]);
      ( "List.tail / set_head",
        [ case "tail" test_tail; case "set_head" test_set_head ] );
      ( "List.drop / drop_while / init",
        [
          case "drop" test_drop;
          case "drop_while" test_drop_while;
          case "init" test_init;
        ] );
      ("List.length", [ case "length" test_length ]);
      ( "List.fold_left",
        [
          case "fold_left" test_fold_left;
          case "via_fold_left" test_via_fold_left;
        ] );
      ("List.reverse", [ case "reverse" test_reverse ]);
      ( "List.append_via_fold_right / concat",
        [
          case "append_via_fold_right" test_append_via_fold_right;
          case "concat" test_concat;
        ] );
      ( "List.increment_each / double_to_string",
        [
          case "increment_each" test_increment_each;
          case "double_to_string" test_double_to_string;
        ] );
      ( "List.map / filter / flat_map",
        [
          case "map" test_map;
          case "filter" test_filter;
          case "flat_map" test_flat_map;
          case "filter_via_flat_map" test_filter_via_flat_map;
        ] );
      ( "List.add_pairwise / zip_with",
        [ case "add_pairwise" test_add_pairwise; case "zip_with" test_zip_with ]
      );
      ("List.has_subsequence", [ case "has_subsequence" test_has_subsequence ]);
    ]
