(* 第8章 テスト (Gen)．サンプリングした値の性質を確かめる． *)
structure GenTest =
struct
  structure G = Gen

  val seed = Rng.simple 1234

  val () = Test.register "ch08 Gen.unit" (fn () =>
    let val (v, _) = G.sample (G.unit 99) seed
    in Test.assertEqual (v, 99)
    end)

  val () = Test.register "ch08 Gen.choose in range" (fn () =>
    let
      fun loop (0, _) = true
        | loop (k, r) =
            let val (n, r') = G.sample (G.choose (10, 20)) r
            in n >= 10 andalso n < 20 andalso loop (k - 1, r')
            end
    in
      Test.assertBool "all in [10,20)" (loop (100, seed))
    end)

  val () = Test.register "ch08 Gen.listOfN length" (fn () =>
    let val (xs, _) = G.sample (G.listOfN 5 (G.unit 0)) seed
    in Test.assertEqual (List.length xs, 5)
    end)

  val () = Test.register "ch08 Gen.pair" (fn () =>
    let val ((a, b), _) = G.sample (G.pair (G.unit 1) (G.unit 2)) seed
    in Test.assertEqual ((a, b), (1, 2))
    end)

  val () = Test.register "ch08 Gen.union picks from both" (fn () =>
    let
      fun loop (0, _, seenA, seenB) = (seenA, seenB)
        | loop (k, r, seenA, seenB) =
            let val (v, r') = G.sample (G.union (G.unit 1) (G.unit 2)) r
            in loop (k - 1, r', seenA orelse v = 1, seenB orelse v = 2)
            end
      val (seenA, seenB) = loop (50, seed, false, false)
    in
      Test.assertBool "saw both 1 and 2" (seenA andalso seenB)
    end)
end
