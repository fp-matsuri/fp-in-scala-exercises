(* exercises のTree実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module T = Datastructures.Tree

let case n f = Alcotest.test_case n `Quick f

(*
        Branch
       /      \
   Branch     Leaf 5
   /    \
  Leaf 1 Leaf 3
*)
let sample = T.Branch (T.Branch (T.Leaf 1, T.Leaf 3), T.Leaf 5)

let test_size () =
  Alcotest.(check int) "leaf" 1 (T.size (T.Leaf 0));
  Alcotest.(check int) "sample" 5 (T.size sample)

let test_maximum () =
  Alcotest.(check int) "leaf" 42 (T.maximum (T.Leaf 42));
  Alcotest.(check int) "sample" 5 (T.maximum sample)

let test_depth () =
  Alcotest.(check int) "leaf depth=0" 0 (T.depth (T.Leaf 0));
  Alcotest.(check int) "sample depth=2" 2 (T.depth sample)

let test_map () =
  Alcotest.(check int)
    "size unchanged" 5
    (T.size (T.map (fun n -> n * 2) sample));
  Alcotest.(check int)
    "maximum doubled" 10
    (T.maximum (T.map (fun n -> n * 2) sample))

let test_fold () =
  (* fold で sum を実装 *)
  let sum t = T.fold (fun n -> n) (fun (l, r) -> l + r) t in
  Alcotest.(check int) "sum" 9 (sum sample)

let test_via_fold () =
  Alcotest.(check int) "size_via_fold" 5 (T.size_via_fold sample);
  Alcotest.(check int) "depth_via_fold" 2 (T.depth_via_fold sample);
  Alcotest.(check int) "maximum_via_fold" 5 (T.maximum_via_fold sample);
  (* map_via_fold は構造を保つので、適用後の size が同じかで確認 *)
  Alcotest.(check int)
    "map_via_fold preserves size" 5
    (T.size (T.map_via_fold (fun n -> n + 1) sample))

let () =
  Alcotest.run "datastructures.Tree"
    [
      ("Tree.size", [ case "size" test_size ]);
      ("Tree.maximum", [ case "maximum" test_maximum ]);
      ("Tree.depth", [ case "depth" test_depth ]);
      ("Tree.map", [ case "map" test_map ]);
      ("Tree.fold", [ case "fold" test_fold; case "via_fold" test_via_fold ]);
    ]
