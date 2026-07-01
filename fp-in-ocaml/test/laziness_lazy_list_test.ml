(* exercises のLazyList実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module L = Laziness.Lazy_list

let int_list = Alcotest.(list int)
let int_list_list = Alcotest.(list (list int))

let test_to_list () =
  Alcotest.(check int_list) "single" [ 1 ] (L.to_list (L.of_list [ 1 ]));
  Alcotest.(check int_list)
    "many" [ 1; 2; 3; 4; 5 ]
    (L.to_list (L.of_list [ 1; 2; 3; 4; 5 ]))

let test_take () =
  Alcotest.(check int_list)
    "take 3 from [1..5]" [ 1; 2; 3 ]
    (L.take 3 (L.of_list [ 1; 2; 3; 4; 5 ]) |> L.to_list);
  Alcotest.(check int_list)
    "take 0" []
    (L.take 0 (L.of_list [ 1; 2; 3 ]) |> L.to_list);
  Alcotest.(check int_list)
    "take more than length" [ 1; 2 ]
    (L.take 10 (L.of_list [ 1; 2 ]) |> L.to_list)

let test_drop () =
  Alcotest.(check int_list)
    "drop 2 from [1..5]" [ 3; 4; 5 ]
    (L.drop 2 (L.of_list [ 1; 2; 3; 4; 5 ]) |> L.to_list);
  Alcotest.(check int_list)
    "drop 0" [ 1; 2; 3 ]
    (L.drop 0 (L.of_list [ 1; 2; 3 ]) |> L.to_list);
  Alcotest.(check int_list)
    "drop more than length" []
    (L.drop 10 (L.of_list [ 1; 2 ]) |> L.to_list)

let test_take_while () =
  Alcotest.(check int_list)
    "take_while < 3" [ 1; 2 ]
    (L.take_while (fun x -> x < 3) (L.of_list [ 1; 2; 3; 4 ]) |> L.to_list);
  Alcotest.(check int_list)
    "take_while < 3 (none match)" []
    (L.take_while (fun x -> x < 3) (L.of_list [ 5; 6 ]) |> L.to_list)

let test_for_all () =
  Alcotest.(check bool)
    "all positive" true
    (L.for_all (fun x -> x > 0) (L.of_list [ 1; 2; 3 ]));
  Alcotest.(check bool)
    "not all positive" false
    (L.for_all (fun x -> x > 0) (L.of_list [ 1; -1; 2 ]))

let test_take_while_via_fold_right () =
  Alcotest.(check int_list)
    "= take_while" [ 1; 2 ]
    (L.take_while_via_fold_right (fun x -> x < 3) (L.of_list [ 1; 2; 3; 4 ])
    |> L.to_list)

let test_head_option () =
  Alcotest.(check (option int)) "empty" None (L.head_option L.nil);
  Alcotest.(check (option int))
    "non-empty" (Some 1)
    (L.head_option (L.of_list [ 1; 2; 3 ]))

let test_map () =
  Alcotest.(check int_list)
    "map (+1)" [ 2; 3; 4 ]
    (L.map (fun x -> x + 1) (L.of_list [ 1; 2; 3 ]) |> L.to_list)

let test_filter () =
  Alcotest.(check int_list)
    "filter even" [ 2; 4 ]
    (L.filter (fun x -> x mod 2 = 0) (L.of_list [ 1; 2; 3; 4 ]) |> L.to_list)

let test_append () =
  Alcotest.(check int_list)
    "[1;2] ++ [3;4]" [ 1; 2; 3; 4 ]
    (L.append (L.of_list [ 1; 2 ]) (lazy (L.of_list [ 3; 4 ])) |> L.to_list)

let test_flat_map () =
  Alcotest.(check int_list)
    "flat_map (fun x -> [x; x])" [ 1; 1; 2; 2; 3; 3 ]
    (L.flat_map (fun x -> L.of_list [ x; x ]) (L.of_list [ 1; 2; 3 ])
    |> L.to_list)

let test_continually () =
  Alcotest.(check int_list)
    "continually 7 |> take 4" [ 7; 7; 7; 7 ]
    (L.continually 7 |> L.take 4 |> L.to_list)

let test_from () =
  Alcotest.(check int_list)
    "from 10 |> take 5" [ 10; 11; 12; 13; 14 ]
    (L.from 10 |> L.take 5 |> L.to_list)

let test_fibs () =
  Alcotest.(check int_list)
    "fibs |> take 10"
    [ 0; 1; 1; 2; 3; 5; 8; 13; 21; 34 ]
    (L.fibs |> L.take 10 |> L.to_list)

let test_unfold () =
  Alcotest.(check int_list)
    "unfold for [0;1;2;3]" [ 0; 1; 2; 3 ]
    (L.unfold 0 (fun s -> if s < 4 then Some (s, s + 1) else None) |> L.to_list)

let test_via_unfold () =
  Alcotest.(check int_list)
    "fibs_via_unfold" [ 0; 1; 1; 2; 3; 5 ]
    (L.fibs_via_unfold |> L.take 6 |> L.to_list);
  Alcotest.(check int_list)
    "from_via_unfold" [ 5; 6; 7 ]
    (L.from_via_unfold 5 |> L.take 3 |> L.to_list);
  Alcotest.(check int_list)
    "continually_via_unfold" [ 9; 9; 9 ]
    (L.continually_via_unfold 9 |> L.take 3 |> L.to_list);
  Alcotest.(check int_list)
    "ones_via_unfold" [ 1; 1; 1 ]
    (L.ones_via_unfold |> L.take 3 |> L.to_list);
  Alcotest.(check int_list) "ones" [ 1; 1; 1 ] (L.ones |> L.take 3 |> L.to_list);
  Alcotest.(check int_list)
    "map_via_unfold" [ 2; 4; 6 ]
    (L.map_via_unfold (fun x -> x * 2) (L.of_list [ 1; 2; 3 ]) |> L.to_list);
  Alcotest.(check int_list)
    "take_via_unfold" [ 1; 2 ]
    (L.take_via_unfold 2 (L.of_list [ 1; 2; 3; 4 ]) |> L.to_list);
  Alcotest.(check int_list)
    "take_while_via_unfold" [ 1; 2 ]
    (L.take_while_via_unfold (fun x -> x < 3) (L.of_list [ 1; 2; 3; 4 ])
    |> L.to_list)

let test_zip_with () =
  Alcotest.(check int_list)
    "zip_with (+)" [ 5; 7; 9 ]
    (L.zip_with ( + ) (L.of_list [ 1; 2; 3 ]) (L.of_list [ 4; 5; 6 ])
    |> L.to_list)

let test_zip_all () =
  let pp fmt (a, b) =
    let opt_pp fmt = function
      | None -> Format.fprintf fmt "None"
      | Some n -> Format.fprintf fmt "Some %d" n
    in
    Format.fprintf fmt "(%a, %a)" opt_pp a opt_pp b
  in
  let testable_pair = Alcotest.testable pp ( = ) in
  Alcotest.(check (list testable_pair))
    "zip_all unequal lengths"
    [ (Some 1, Some 4); (Some 2, Some 5); (Some 3, None) ]
    (L.zip_all (L.of_list [ 1; 2; 3 ]) (L.of_list [ 4; 5 ]) |> L.to_list)

let test_starts_with () =
  Alcotest.(check bool)
    "[1;2;3] starts_with [1;2]" true
    (L.starts_with (L.of_list [ 1; 2 ]) (L.of_list [ 1; 2; 3 ]));
  Alcotest.(check bool)
    "[1;2;3] starts_with [2;3]" false
    (L.starts_with (L.of_list [ 2; 3 ]) (L.of_list [ 1; 2; 3 ]));
  Alcotest.(check bool)
    "[1;2;3] starts_with []" true
    (L.starts_with L.nil (L.of_list [ 1; 2; 3 ]));
  Alcotest.(check bool)
    "[1;2] starts_with [1;2;3]" false
    (L.starts_with (L.of_list [ 1; 2; 3 ]) (L.of_list [ 1; 2 ]))

let test_tails () =
  Alcotest.(check int_list_list)
    "tails of [1;2;3]"
    [ [ 1; 2; 3 ]; [ 2; 3 ]; [ 3 ]; [] ]
    (L.tails (L.of_list [ 1; 2; 3 ]) |> L.to_list |> List.map L.to_list)

let test_scan_right () =
  Alcotest.(check int_list)
    "scan_right (+) 0 of [1;2;3] = [6;5;3;0]" [ 6; 5; 3; 0 ]
    (L.scan_right 0 (fun a b -> a + Lazy.force b) (L.of_list [ 1; 2; 3 ])
    |> L.to_list)

let case n f = Alcotest.test_case n `Quick f

let () =
  Alcotest.run "laziness.LazyList"
    [
      ("LazyList.to_list", [ case "to_list" test_to_list ]);
      ("LazyList.take / drop", [ case "take" test_take; case "drop" test_drop ]);
      ("LazyList.take_while", [ case "take_while" test_take_while ]);
      ("LazyList.for_all", [ case "for_all" test_for_all ]);
      ( "LazyList.take_while_via_fold_right",
        [ case "take_while_via_fold_right" test_take_while_via_fold_right ] );
      ("LazyList.head_option", [ case "head_option" test_head_option ]);
      ( "LazyList.map / filter / append / flat_map",
        [
          case "map" test_map;
          case "filter" test_filter;
          case "append" test_append;
          case "flat_map" test_flat_map;
        ] );
      ( "LazyList.continually / from / fibs / unfold",
        [
          case "continually" test_continually;
          case "from" test_from;
          case "fibs" test_fibs;
          case "unfold" test_unfold;
        ] );
      ("LazyList.via_unfold", [ case "various via_unfold" test_via_unfold ]);
      ( "LazyList.zip_with / zip_all",
        [ case "zip_with" test_zip_with; case "zip_all" test_zip_all ] );
      ("LazyList.starts_with", [ case "starts_with" test_starts_with ]);
      ("LazyList.tails", [ case "tails" test_tails ]);
      ("LazyList.scan_right", [ case "scan_right" test_scan_right ]);
    ]
