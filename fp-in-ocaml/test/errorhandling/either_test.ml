(* exercises のEither実装を検証するテスト。
   [open Exercises]を[open Answers]に差し替えれば解答例の動作確認になる。

open Answers
*)
open Exercises
module E = Errorhandling.Either

let pp_t pp_l pp_r fmt = function
  | E.Left e -> Format.fprintf fmt "Left %a" pp_l e
  | E.Right a -> Format.fprintf fmt "Right %a" pp_r a

let eq_t eql eqr a b =
  match (a, b) with
  | E.Left x, E.Left y -> eql x y
  | E.Right x, E.Right y -> eqr x y
  | _ -> false

let either_testable l r =
  Alcotest.testable (pp_t (Alcotest.pp l) (Alcotest.pp r)) (eq_t ( = ) ( = ))

let either_si = either_testable Alcotest.string Alcotest.int
let either_s_pair = either_testable Alcotest.string Alcotest.(pair string int)

let either_sl_pair =
  either_testable (Alcotest.list Alcotest.string) Alcotest.(pair string int)

let either_s_il = either_testable Alcotest.string Alcotest.(list int)

let either_sl_il =
  either_testable (Alcotest.list Alcotest.string) Alcotest.(list int)

let case n f = Alcotest.test_case n `Quick f

let test_map () =
  Alcotest.(check either_si)
    "Left preserved" (E.Left "err")
    (E.map (fun n -> n / 2) (E.Left "err"));
  Alcotest.(check either_si)
    "Right halved" (E.Right 3)
    (E.map (fun n -> n / 2) (E.Right 6))

let test_flat_map () =
  let f n = if n mod 2 = 0 then E.Right (n / 2) else E.Left "odd" in
  Alcotest.(check either_si)
    "Left preserved" (E.Left "x")
    (E.flat_map f (E.Left "x"));
  Alcotest.(check either_si) "Right even" (E.Right 3) (E.flat_map f (E.Right 6));
  Alcotest.(check either_si)
    "Right odd" (E.Left "odd") (E.flat_map f (E.Right 5))

let test_or_else () =
  let alt = E.Right 999 in
  Alcotest.(check either_si) "Left -> alt" alt (E.or_else alt (E.Left "x"));
  Alcotest.(check either_si)
    "Right preserved" (E.Right 1)
    (E.or_else alt (E.Right 1))

(* バリデーション例: 名前と年齢から人を作る。 *)
let make_name s = if s = "" then E.Left "Name is empty." else E.Right s
let make_age n = if n < 0 then E.Left "Age is out of range." else E.Right n
let make_name_l s = if s = "" then E.Left [ "Name is empty." ] else E.Right s

let make_age_l n =
  if n < 0 then E.Left [ "Age is out of range." ] else E.Right n

let test_map2 () =
  Alcotest.(check either_s_pair)
    "valid"
    (E.Right ("Alice", 20))
    (E.map2 (fun n a -> (n, a)) (make_name "Alice") (make_age 20));
  Alcotest.(check either_s_pair)
    "empty name" (E.Left "Name is empty.")
    (E.map2 (fun n a -> (n, a)) (make_name "") (make_age 20));
  Alcotest.(check either_s_pair)
    "negative age" (E.Left "Age is out of range.")
    (E.map2 (fun n a -> (n, a)) (make_name "Alice") (make_age (-1)));
  Alcotest.(check either_s_pair)
    "both invalid: first wins" (E.Left "Name is empty.")
    (E.map2 (fun n a -> (n, a)) (make_name "") (make_age (-1)))

let test_traverse () =
  Alcotest.(check either_s_il)
    "all valid"
    (E.Right [ 1; 2; 3 ])
    (E.traverse make_age [ 1; 2; 3 ]);
  Alcotest.(check either_s_il)
    "has negative" (E.Left "Age is out of range.")
    (E.traverse make_age [ 1; -1; 3 ]);
  Alcotest.(check either_s_il) "empty" (E.Right []) (E.traverse make_age [])

let test_sequence () =
  Alcotest.(check either_s_il)
    "all valid"
    (E.Right [ 1; 2; 3 ])
    (E.sequence [ E.Right 1; E.Right 2; E.Right 3 ]);
  Alcotest.(check either_s_il)
    "has Left" (E.Left "err")
    (E.sequence [ E.Right 1; E.Left "err"; E.Right 3 ]);
  Alcotest.(check either_s_il) "empty" (E.Right []) (E.sequence [])

let test_map2_all () =
  Alcotest.(check either_sl_pair)
    "valid"
    (E.Right ("Alice", 20))
    (E.map2_all (fun n a -> (n, a)) (make_name_l "Alice") (make_age_l 20));
  Alcotest.(check either_sl_pair)
    "empty name" (E.Left [ "Name is empty." ])
    (E.map2_all (fun n a -> (n, a)) (make_name_l "") (make_age_l 20));
  Alcotest.(check either_sl_pair)
    "negative age" (E.Left [ "Age is out of range." ])
    (E.map2_all (fun n a -> (n, a)) (make_name_l "Alice") (make_age_l (-1)));
  Alcotest.(check either_sl_pair)
    "both invalid: accumulated"
    (E.Left [ "Name is empty."; "Age is out of range." ])
    (E.map2_all (fun n a -> (n, a)) (make_name_l "") (make_age_l (-1)))

let test_traverse_all () =
  Alcotest.(check either_sl_il)
    "all valid"
    (E.Right [ 1; 2; 3 ])
    (E.traverse_all make_age_l [ 1; 2; 3 ]);
  Alcotest.(check either_sl_il)
    "two negatives accumulated"
    (E.Left [ "Age is out of range."; "Age is out of range." ])
    (E.traverse_all make_age_l [ 1; -1; -2 ]);
  Alcotest.(check either_sl_il)
    "empty" (E.Right [])
    (E.traverse_all make_age_l [])

let test_sequence_all () =
  Alcotest.(check either_sl_il)
    "all valid"
    (E.Right [ 1; 2; 3 ])
    (E.sequence_all [ E.Right 1; E.Right 2; E.Right 3 ]);
  Alcotest.(check either_sl_il)
    "two Lefts accumulated"
    (E.Left [ "a"; "b" ])
    (E.sequence_all [ E.Right 1; E.Left [ "a" ]; E.Left [ "b" ] ]);
  Alcotest.(check either_sl_il) "empty" (E.Right []) (E.sequence_all [])

let () =
  Alcotest.run "errorhandling.Either"
    [
      ( "Either.map / flat_map / or_else",
        [
          case "map" test_map;
          case "flat_map" test_flat_map;
          case "or_else" test_or_else;
        ] );
      ("Either.map2", [ case "map2" test_map2 ]);
      ( "Either.traverse / sequence",
        [ case "traverse" test_traverse; case "sequence" test_sequence ] );
      ("Either.map2_all", [ case "map2_all" test_map2_all ]);
      ( "Either.traverse_all / sequence_all",
        [
          case "traverse_all" test_traverse_all;
          case "sequence_all" test_sequence_all;
        ] );
    ]
