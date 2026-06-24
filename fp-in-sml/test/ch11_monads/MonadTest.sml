(* 第11章 テスト (Monad)．MonadUtil を各インスタンスに適用して派生関数を確かめる． *)
structure MonadTest =
struct
  structure OptU = MonadUtil(OptionMonad)
  structure ListU = MonadUtil(ListMonad)
  structure IntState = StateMonadFn(type s = int)
  structure StateU = MonadUtil(IntState)

  val () = Test.register "ch11 Option map/map2" (fn () =>
    ( Test.assertEqual (OptU.map (fn x => x + 1) (SOME 3), SOME 4)
    ; Test.assertEqual (OptU.map2 (op+) (SOME 3) (SOME 4), SOME 7)
    ; Test.assertEqual (OptU.map2 (op+) (SOME 3) NONE, NONE : int option)
    ))

  val () = Test.register "ch11 Option sequence" (fn () =>
    ( Test.assertEqual (OptU.sequence [SOME 1, SOME 2, SOME 3], SOME [1, 2, 3])
    ; Test.assertEqual
        (OptU.sequence [SOME 1, NONE, SOME 3], NONE : int list option)
    ))

  val () = Test.register "ch11 Option join" (fn () =>
    ( Test.assertEqual (OptU.join (SOME (SOME 5)), SOME 5)
    ; Test.assertEqual (OptU.join (SOME NONE), NONE : int option)
    ))

  val () = Test.register "ch11 List map/sequence (cartesian)" (fn () =>
    ( Test.assertEqual (ListU.map (fn x => x * 2) [1, 2, 3], [2, 4, 6])
    ; Test.assertEqual (ListU.sequence [[1, 2], [3]], [[1, 3], [2, 3]])
    ))

  val () = Test.register "ch11 List replicateM" (fn () =>
    Test.assertEqual
      (ListU.replicateM 2 [0, 1], [[0, 0], [0, 1], [1, 0], [1, 1]]))

  val () = Test.register "ch11 State monad via MonadUtil" (fn () =>
    let
      val prog = StateU.map2 (op+) (State.unit 3) (State.unit 4)
      val (a, _) = State.run prog 0
    in
      Test.assertEqual (a, 7)
    end)

  val () = Test.register "ch11 State sequence threads state" (fn () =>
    let
      val tick =
        State.flatMap (fn n => State.map (fn _ => n) (State.set (n + 1)))
          State.get
      val prog = StateU.sequence [tick, tick, tick]
      val (xs, s) = State.run prog 0
    in
      Test.assertEqual ((xs, s), ([0, 1, 2], 3))
    end)
end
