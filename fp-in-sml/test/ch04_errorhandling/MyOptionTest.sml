(* 第4章 テスト (MyOption)．Basis の Option を参照実装に差分テスト． *)
structure MyOptionTest =
struct
  structure M = MyOption

  fun showOpt NONE = "NONE"
    | showOpt (SOME n) = "SOME " ^ Int.toString n

  fun showOptList os =
    "[" ^ String.concatWith "," (List.map showOpt os) ^ "]"

  (* int option のジェネレータ *)
  val optGen = Pbt.bind Pbt.bool (fn b =>
    if b then Pbt.map SOME Pbt.int else Pbt.map (fn _ => NONE) Pbt.int)

  fun seqRef os =
    List.foldr
      (fn (NONE, _) => NONE
        | (_, NONE) => NONE
        | (SOME x, SOME acc) => SOME (x :: acc)) (SOME []) os

  val () = Test.register "ch04 MyOption.map" (fn () =>
    Test.forAll showOpt optGen (fn opt =>
      M.toOption (M.map (fn x => x + 1) (M.fromOption opt))
      = Option.map (fn x => x + 1) opt))

  val () = Test.register "ch04 MyOption.getOrElse" (fn () =>
    Test.forAll showOpt optGen (fn opt =>
      M.getOrElse (M.fromOption opt) 0 = Option.getOpt (opt, 0)))

  val () = Test.register "ch04 MyOption.flatMap/orElse/filter" (fn () =>
    ( Test.assertEqual
        (M.toOption (M.flatMap (fn x => M.Some (x * 2)) (M.Some 3)), SOME 6)
    ; Test.assertEqual
        (M.toOption (M.flatMap (fn x => M.Some (x * 2)) M.None), NONE)
    ; Test.assertEqual (M.toOption (M.orElse M.None (M.Some 5)), SOME 5)
    ; Test.assertEqual (M.toOption (M.orElse (M.Some 1) (M.Some 5)), SOME 1)
    ; Test.assertEqual
        (M.toOption (M.filter (fn x => x > 0) (M.Some 3)), SOME 3)
    ; Test.assertEqual (M.toOption (M.filter (fn x => x > 0) (M.Some ~3)), NONE)
    ))

  val () = Test.register "ch04 MyOption.map2" (fn () =>
    ( Test.assertEqual (M.toOption (M.map2 (op+) (M.Some 3) (M.Some 4)), SOME 7)
    ; Test.assertEqual (M.toOption (M.map2 (op+) (M.Some 3) M.None), NONE)
    ))

  val () = Test.register "ch04 MyOption.sequence" (fn () =>
    Test.forAll showOptList (Pbt.list optGen) (fn os =>
      let val got = M.toOption (M.sequence (List.map M.fromOption os))
      in got = seqRef os
      end))
end
