(* 第13章 テスト (MyIO)．ref を観測して「run するまで効果が起きない」ことを確かめる． *)
structure MyIOTest =
struct
  val () = Test.register "ch13 IO defers effects until run" (fn () =>
    let
      val log = ref ([] : int list)
      fun push x =
        MyIO.effect (fn () => log := x :: !log)
      val prog =
        MyIO.flatMap (fn _ => MyIO.flatMap (fn _ => MyIO.unit 99) (push 2))
          (push 1)
    in
      Test.assertEqual (!log, []); (* まだ何も起きていない *)
      Test.assertEqual (MyIO.run prog, 99);
      Test.assertEqual
        (!log, [2, 1]) (* run して初めて効果が起きる *)
    end)

  val () = Test.register "ch13 IO map" (fn () =>
    Test.assertEqual (MyIO.run (MyIO.map (fn x => x + 1) (MyIO.unit 10)), 11))

  val () = Test.register "ch13 IO sequence runs left to right" (fn () =>
    let
      val log = ref ([] : int list)
      fun push x =
        MyIO.effect (fn () => (log := x :: !log; x))
      val xs = MyIO.run (MyIO.sequence [push 1, push 2, push 3])
    in
      Test.assertEqual (xs, [1, 2, 3]);
      Test.assertEqual (!log, [3, 2, 1])
    end)
end
