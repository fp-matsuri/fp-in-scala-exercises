(* 第15章 テスト (Process)．apply で入力を流し，出力リストを確かめる． *)
structure ProcessTest =
struct
  structure P = Process

  fun realListEq (xs, ys) =
    ListPair.allEq (fn (a, b) => Real.abs (a - b) < 1.0E~9) (xs, ys)
  fun realListShow xs =
    "[" ^ String.concatWith "," (List.map Real.toString xs) ^ "]"

  val () = Test.register "ch15 Process.lift" (fn () =>
    Test.assertEqual (P.apply (P.lift (fn x => x + 1)) [1, 2, 3], [2, 3, 4]))

  val () = Test.register "ch15 Process.filter" (fn () =>
    Test.assertEqual
      (P.apply (P.filter (fn x => x mod 2 = 0)) [1, 2, 3, 4], [2, 4]))

  val () = Test.register "ch15 Process.take" (fn () =>
    Test.assertEqual (P.apply (P.take 2) [1, 2, 3, 4], [1, 2]))

  val () = Test.register "ch15 Process.sum (running)" (fn () =>
    Test.assertEqualBy {eq = realListEq, show = realListShow}
      (P.apply P.sum [1.0, 2.0, 3.0], [1.0, 3.0, 6.0]))

  val () = Test.register "ch15 Process.count" (fn () =>
    Test.assertEqual (P.apply P.count [#"a", #"b", #"c"], [1, 2, 3]))

  val () = Test.register "ch15 Process.pipe (compose)" (fn () =>
    Test.assertEqual
      ( P.apply
          (P.pipe (P.lift (fn x => x + 1)) (P.filter (fn x => x mod 2 = 0)))
          [1, 2, 3, 4]
      , [2, 4]
      ))
end
