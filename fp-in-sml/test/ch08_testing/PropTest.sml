(* 第8章 テスト (Prop)．自作 Prop が成功/失敗を正しく判定するか． *)
structure PropTest =
struct
  structure P = Prop

  val seed = Rng.simple 99

  val () = Test.register "ch08 Prop true property passes" (fn () =>
    let
      val prop = P.forAll (Gen.choose (0, 100)) Int.toString (fn n =>
        n >= 0 andalso n < 100)
    in
      Test.assertBool "Passed" (P.isPassed (P.run prop 100 seed))
    end)

  val () = Test.register "ch08 Prop false property fails" (fn () =>
    let
      val prop = P.forAll (Gen.unit 5) Int.toString (fn n => n <> 5)
    in
      case P.run prop 100 seed of
        P.Falsified s => Test.assertEqual (s, "5")
      | P.Passed => Test.assertBool "should have falsified" false
    end)

  val () = Test.register "ch08 Prop andProp" (fn () =>
    let
      val good = P.forAll (Gen.choose (0, 10)) Int.toString (fn n => n < 10)
      val bad = P.forAll (Gen.unit 1) Int.toString (fn _ => false)
    in
      Test.assertBool "good && good passes" (P.isPassed
        (P.run (P.andProp (good, good)) 50 seed));
      Test.assertBool "good && bad fails" (not (P.isPassed
        (P.run (P.andProp (good, bad)) 50 seed)))
    end)
end
