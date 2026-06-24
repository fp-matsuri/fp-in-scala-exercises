(* exercises のRng実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module R = State.Rng.Make (State.Rng.Simple)

let seeds = List.map Int64.of_int [ 0; 1; 42; 12345; 999_999; -1; -42 ]
let case n f = Alcotest.test_case n `Quick f

let test_non_negative_int () =
  List.iter
    (fun seed ->
      let n, _ = R.non_negative_int (R.make seed) in
      Alcotest.(check bool)
        (Printf.sprintf "non_negative_int seed=%Ld" seed)
        true (n >= 0))
    seeds

let test_double () =
  List.iter
    (fun seed ->
      let d, _ = R.double (R.make seed) in
      Alcotest.(check bool)
        (Printf.sprintf "double in [0,1) seed=%Ld" seed)
        true
        (d >= 0.0 && d < 1.0))
    seeds

let test_int_double () =
  let (_, d), _ = R.int_double (R.make 1L) in
  Alcotest.(check bool) "double part in [0,1)" true (d >= 0.0 && d < 1.0)

let test_double_int () =
  let (d, _), _ = R.double_int (R.make 1L) in
  Alcotest.(check bool) "double part in [0,1)" true (d >= 0.0 && d < 1.0)

let test_double3 () =
  let (d1, d2, d3), _ = R.double3 (R.make 1L) in
  let ok d = d >= 0.0 && d < 1.0 in
  Alcotest.(check bool) "d1" true (ok d1);
  Alcotest.(check bool) "d2" true (ok d2);
  Alcotest.(check bool) "d3" true (ok d3)

let test_ints () =
  let xs, _ = R.ints 5 (R.make 1L) in
  Alcotest.(check int) "length" 5 (List.length xs);
  (* 同じシードで再生成すると同じ結果 *)
  let xs', _ = R.ints 5 (R.make 1L) in
  Alcotest.(check (list int)) "deterministic" xs xs'

let test_map () =
  let r = R.make 42L in
  let n, _ = R.next_int r in
  let s, _ = R.map string_of_int R.int r in
  Alcotest.(check string) "map = string_of_int" (string_of_int n) s

let test_map2 () =
  let r = R.make 42L in
  let r1, r2 = R.next_int r in
  let r3, _ = R.next_int r2 in
  let sum, _ = R.map2 ( + ) R.int R.int r in
  Alcotest.(check int) "map2 sums" (r1 + r3) sum

let test_sequence () =
  let r = R.make 1L in
  let rs = R.sequence [ R.unit 1; R.unit 2; R.unit 3 ] in
  let xs, _ = rs r in
  Alcotest.(check (list int)) "sequence of unit" [ 1; 2; 3 ] xs

let test_flat_map () =
  let r = R.make 7L in
  let mk = R.flat_map (fun a -> R.map (fun b -> a + b) R.int) R.int in
  let v, _ = mk r in
  let a, r2 = R.next_int r in
  let b, _ = R.next_int r2 in
  Alcotest.(check int) "flat_map equiv to map2" (a + b) v

let test_via_flat_map () =
  let r = R.make 7L in
  let m1, _ = R.map (fun a -> a + 1) R.int r in
  let m2, _ = R.map_via_flat_map (fun a -> a + 1) R.int r in
  Alcotest.(check int) "map_via_flat_map" m1 m2;
  let m3, _ = R.map2 ( + ) R.int R.int r in
  let m4, _ = R.map2_via_flat_map ( + ) R.int R.int r in
  Alcotest.(check int) "map2_via_flat_map" m3 m4

let test_double_via_map () =
  let r = R.make 11L in
  let d1, _ = R.double r in
  let d2, _ = R.double_via_map r in
  Alcotest.(check (float 1e-12)) "double_via_map" d1 d2

let () =
  Alcotest.run "state.Rng"
    [
      ("Rng.non_negative_int", [ case "non_negative_int" test_non_negative_int ]);
      ("Rng.double", [ case "double" test_double ]);
      ( "Rng.int_double / double_int / double3",
        [
          case "int_double" test_int_double;
          case "double_int" test_double_int;
          case "double3" test_double3;
        ] );
      ("Rng.ints", [ case "ints" test_ints ]);
      ("Rng.map / map2", [ case "map" test_map; case "map2" test_map2 ]);
      ("Rng.sequence", [ case "sequence" test_sequence ]);
      ("Rng.flat_map", [ case "flat_map" test_flat_map ]);
      ( "Rng.via_flat_map",
        [
          case "map_via_flat_map / map2_via_flat_map" test_via_flat_map;
          case "double_via_map" test_double_via_map;
        ] );
    ]
