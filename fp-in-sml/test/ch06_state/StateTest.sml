(* 第6章 テスト (State)． *)
structure StateTest =
struct
  structure S = State

  val () = Test.register "ch06 State get/set" (fn () =>
    let
      val prog =
        S.flatMap (fn x => S.flatMap (fn _ => S.unit x) (S.set (x + 1))) S.get
      val (a, s) = S.run prog 10
    in
      Test.assertEqual ((a, s), (10, 11))
    end)

  val () = Test.register "ch06 State.modify" (fn () =>
    let val (_, s) = S.run (S.modify (fn n => n * 2)) 21
    in Test.assertEqual (s, 42)
    end)

  val () = Test.register "ch06 State.map2" (fn () =>
    let
      val p = S.map2 (op+) (S.unit 3) (S.unit 4)
      val (a, _) = S.run p 0
    in
      Test.assertEqual (a, 7)
    end)

  val () = Test.register "ch06 State.sequence" (fn () =>
    let
      val p = S.sequence [S.unit 1, S.unit 2, S.unit 3]
      val (xs, _) = S.run p 0
    in
      Test.assertEqual (xs, [1, 2, 3])
    end)

  val () = Test.register "ch06 State counter via sequence" (fn () =>
    let
      val tick = S.flatMap (fn n => S.map (fn _ => n) (S.set (n + 1))) S.get
      val p = S.sequence [tick, tick, tick]
      val (xs, s) = S.run p 0
    in
      Test.assertEqual ((xs, s), ([0, 1, 2], 3))
    end)
end
