(* 下のコメントを外すと正答版の動作を確認できます *)
(* open Answers *)

open Getting_started

let factorial_reference n =
  let rec go i acc = if i <= 0 then acc else go (i - 1) (i * acc) in
  go n 1

let factorial_test =
  QCheck.Test.make ~count:1000 ~name:"factorial"
    QCheck.(int_range 1 20)
    (fun n -> My_program.factorial n = factorial_reference n)

let test_fib () =
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
  |> Array.iteri (fun i expected ->
      Alcotest.(check int)
        (Printf.sprintf "fib %d" i)
        expected (My_program.fib i))

let sorted_seq_arb =
  QCheck.(make ~print:Print.(list int) Gen.(list int >|= List.sort compare))

let unsorted_seq_arb =
  QCheck.(
    make
      ~print:Print.(list int)
      Gen.(
        list_size (int_range 2 19) (int_range 0 19)
        >|= List.mapi (fun i x -> if i mod 2 = 0 then x + 100 else x - 100)))

let sorted_for_sorted_test =
  QCheck.Test.make ~count:1000 ~name:"sorted? for sorted" sorted_seq_arb
    (fun xs -> Polymorphic_functions.sorted (Array.of_list xs) ( > ))

let sorted_for_unsorted_test =
  QCheck.Test.make ~count:1000 ~name:"sorted? for unsorted" unsorted_seq_arb
    (fun xs -> not (Polymorphic_functions.sorted (Array.of_list xs) ( > )))

let curry_test =
  QCheck.Test.make ~count:1000 ~name:"curry"
    QCheck.(pair int int)
    (fun (n, m) ->
      let mul = Polymorphic_functions.curry (fun (a, b) -> a * b) in
      mul n m = n * m)

let uncurry_test =
  QCheck.Test.make ~count:1000 ~name:"uncurry"
    QCheck.(pair int int)
    (fun (n, m) ->
      let mul = Polymorphic_functions.uncurry (fun a b -> a * b) in
      mul (n, m) = n * m)

let compose_test =
  QCheck.Test.make ~count:1000 ~name:"compose"
    QCheck.(pair int int)
    (fun (n, m) ->
      let f = Polymorphic_functions.compose (fun b -> n * b) (fun a -> m * a) in
      f 1 = n * m)

let to_alco = QCheck_alcotest.to_alcotest

let () =
  Alcotest.run "getting_started"
    [
      ("My_program.factorial", [ to_alco factorial_test ]);
      ("My_program.fib", [ Alcotest.test_case "0..20" `Quick test_fib ]);
      ( "Polymorphic_functions.sorted",
        [ to_alco sorted_for_sorted_test; to_alco sorted_for_unsorted_test ] );
      ("Polymorphic_functions.curry", [ to_alco curry_test ]);
      ("Polymorphic_functions.uncurry", [ to_alco uncurry_test ]);
      ("Polymorphic_functions.compose", [ to_alco compose_test ]);
    ]
