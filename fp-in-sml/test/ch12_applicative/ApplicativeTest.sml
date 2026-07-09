(* 第12章 テスト (Applicative)．Validation が誤りを蓄積することも確かめる． *)
structure ApplicativeTest =
struct
  structure OptU = ApplicativeUtil(OptionAp)
  structure ListU = ApplicativeUtil(ListAp)
  structure StrVal = ValidationAp(type e = string)
  structure ValU = ApplicativeUtil(StrVal)

  val () = Test.register "ch12 Option map/sequence" (fn () =>
    ( Test.assertEqual (OptU.map (fn x => x + 1) (SOME 3), SOME 4)
    ; Test.assertEqual (OptU.sequence [SOME 1, SOME 2, SOME 3], SOME [1, 2, 3])
    ; Test.assertEqual
        (OptU.sequence [SOME 1, NONE, SOME 3], NONE : int list option)
    ))

  val () = Test.register "ch12 List ap (cartesian)" (fn () =>
    Test.assertEqual
      (ListU.ap [fn x => x + 1, fn x => x * 10] [1, 2], [2, 3, 10, 20]))

  val () = Test.register "ch12 Validation success" (fn () =>
    Test.assertEqual
      ( ValU.sequence [Valid 1, Valid 2, Valid 3]
      , Valid [1, 2, 3] : (string, int list) validation
      ))

  val () = Test.register "ch12 Validation accumulates errors" (fn () =>
    Test.assertEqual
      ( ValU.sequence [Valid 1, Invalid ["e1"], Invalid ["e2"]]
      , Invalid ["e1", "e2"] : (string, int list) validation
      ))

  val () = Test.register "ch12 Validation map2 accumulates" (fn () =>
    Test.assertEqual
      ( StrVal.map2 (fn (x, _) => x) (Invalid ["a"]) (Invalid ["b"])
      , Invalid ["a", "b"] : (string, int) validation
      ))
end
