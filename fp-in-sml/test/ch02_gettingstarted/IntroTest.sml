(* 第2章 テスト (Intro)． *)
structure IntroTest =
struct
  val () = Test.register "ch02 Intro.fib" (fn () =>
    let
      val expected = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
      fun loop (_, []) = ()
        | loop (i, e :: es) =
            (Test.assertEqual (Intro.fib i, e); loop (i + 1, es))
    in
      loop (0, expected)
    end)

  val () = Test.register "ch02 Intro.isSorted" (fn () =>
    let
      val le = fn (a: int, b: int) => a <= b
    in
      Test.assertBool "ascending" (Intro.isSorted ([1, 2, 3, 3, 5], le));
      Test.assertBool "single" (Intro.isSorted ([42], le));
      Test.assertBool "empty" (Intro.isSorted ([], le));
      Test.assertBool "descending is not sorted" (not
        (Intro.isSorted ([1, 3, 2], le)))
    end)

  val () = Test.register "ch02 Intro.curry/uncurry" (fn () =>
    let
      val add = fn (a: int, b: int) => a + b
    in
      Test.assertEqual (Intro.curry add 3 4, 7);
      Test.assertEqual (Intro.uncurry (Intro.curry add) (5, 6), 11)
    end)

  val () = Test.register "ch02 Intro.compose" (fn () =>
    let
      val inc = fn (x: int) => x + 1
      val dbl = fn (x: int) => x * 2
    in
      Test.assertEqual (Intro.compose inc dbl 10, 21)
    end)
end
