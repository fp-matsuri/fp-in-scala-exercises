(*
[open Exercises]を[open Answers]に差し替えると正答版の動作を確認できます。

open Answers
*)
open Exercises
open Getting_started

let case n f = Alcotest.test_case n `Quick f

let factorial_reference n =
  let rec go i acc = if i <= 0 then acc else go (i - 1) (i * acc) in
  go n 1

let test_factorial () =
  List.iter
    (fun n ->
      Alcotest.(check int)
        (Printf.sprintf "factorial %d" n)
        (factorial_reference n) (My_program.factorial n))
    [ 1; 2; 3; 5; 10; 15; 20 ]

let test_fib () =
  let expected =
    [|
      0;
      1;
      1;
      2;
      3;
      5;
      8;
      13;
      21;
      34;
      55;
      89;
      144;
      233;
      377;
      610;
      987;
      1597;
      2584;
      4181;
      6765;
    |]
  in
  Array.iteri
    (fun i e ->
      Alcotest.(check int) (Printf.sprintf "fib %d" i) e (My_program.fib i))
    expected

let test_sorted_for_sorted () =
  List.iter
    (fun xs ->
      Alcotest.(check bool)
        (Printf.sprintf "sorted? %s"
           (String.concat ";" (List.map string_of_int xs)))
        true
        (Polymorphic_functions.sorted (Array.of_list xs) ( > )))
    [ []; [ 1 ]; [ 1; 2; 3; 4; 5 ]; [ -3; -1; 0; 2; 5 ]; [ 0; 0; 1 ] ]

let test_sorted_for_unsorted () =
  List.iter
    (fun xs ->
      Alcotest.(check bool)
        (Printf.sprintf "unsorted? %s"
           (String.concat ";" (List.map string_of_int xs)))
        false
        (Polymorphic_functions.sorted (Array.of_list xs) ( > )))
    [ [ 2; 1 ]; [ 1; 3; 2; 4 ]; [ 5; 4; 3; 2; 1 ]; [ 0; -1 ] ]

let test_curry () =
  let mul = Polymorphic_functions.curry (fun (a, b) -> a * b) in
  List.iter
    (fun (n, m) ->
      Alcotest.(check int) (Printf.sprintf "%d * %d" n m) (n * m) (mul n m))
    [ (3, 4); (-2, 5); (0, 100); (7, 0); (-3, -7) ]

let test_uncurry () =
  let mul = Polymorphic_functions.uncurry (fun a b -> a * b) in
  List.iter
    (fun (n, m) ->
      Alcotest.(check int) (Printf.sprintf "%d * %d" n m) (n * m) (mul (n, m)))
    [ (3, 4); (-2, 5); (0, 100); (7, 0); (-3, -7) ]

let test_compose () =
  List.iter
    (fun (n, m) ->
      let f = Polymorphic_functions.compose (fun b -> n * b) (fun a -> m * a) in
      Alcotest.(check int)
        (Printf.sprintf "compose with (%d,%d)" n m)
        (n * m) (f 1))
    [ (3, 4); (-2, 5); (0, 100); (7, 0); (-3, -7) ]

let () =
  Alcotest.run "getting_started"
    [
      ("My_program.factorial", [ case "samples" test_factorial ]);
      ("My_program.fib", [ case "0..20" test_fib ]);
      ( "Polymorphic_functions.sorted",
        [
          case "sorted? for sorted" test_sorted_for_sorted;
          case "sorted? for unsorted" test_sorted_for_unsorted;
        ] );
      ("Polymorphic_functions.curry", [ case "curry" test_curry ]);
      ("Polymorphic_functions.uncurry", [ case "uncurry" test_uncurry ]);
      ("Polymorphic_functions.compose", [ case "compose" test_compose ]);
    ]
