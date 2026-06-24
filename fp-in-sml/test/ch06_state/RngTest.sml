(* 第6章 テスト (Rng)．乱数なので「性質」と「再現性」を確かめる． *)
structure RngTest =
struct
  structure R = Rng

  fun showInt n = Int.toString n

  val () = Test.register "ch06 Rng deterministic" (fn () =>
    let
      val (a, _) = R.nextInt (R.simple 42)
      val (b, _) = R.nextInt (R.simple 42)
    in
      Test.assertEqual (a, b)
    end)

  val () = Test.register "ch06 Rng.nonNegativeInt >= 0" (fn () =>
    Test.forAll showInt Pbt.int (fn seed =>
      let val (n, _) = R.nonNegativeInt (R.simple seed)
      in n >= 0
      end))

  val () = Test.register "ch06 Rng.double in [0,1)" (fn () =>
    Test.forAll showInt Pbt.int (fn seed =>
      let val (d, _) = R.double (R.simple seed)
      in d >= 0.0 andalso d < 1.0
      end))

  val () = Test.register "ch06 Rng.ints length" (fn () =>
    let val (xs, _) = R.ints 5 (R.simple 1)
    in Test.assertEqual (List.length xs, 5)
    end)

  val () = Test.register "ch06 Rng.map" (fn () =>
    let
      val rb = R.map (fn n => n mod 2) R.nonNegativeInt
      val (v, _) = rb (R.simple 7)
    in
      Test.assertBool "0 or 1" (v = 0 orelse v = 1)
    end)

  val () = Test.register "ch06 Rng.sequence/unit" (fn () =>
    let val (xs, _) = R.sequence [R.unit 1, R.unit 2, R.unit 3] (R.simple 1)
    in Test.assertEqual (xs, [1, 2, 3])
    end)
end
