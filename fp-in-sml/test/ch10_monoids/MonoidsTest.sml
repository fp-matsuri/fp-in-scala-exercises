(* 第10章 テスト (モノイド)．functor を各インスタンスに適用して派生関数を試す． *)
structure MonoidsTest =
struct
  structure IntAddOps = MonoidOps(IntAdd)
  structure IntMulOps = MonoidOps(IntMul)
  structure StrOps = MonoidOps(StringM)
  structure OrOps = MonoidOps(BoolOr)
  structure AndOps = MonoidOps(BoolAnd)

  val () = Test.register "ch10 intAddition concatenate" (fn () =>
    Test.assertEqual (IntAddOps.concatenate [1, 2, 3, 4], 10))

  val () = Test.register "ch10 intMultiplication concatenate" (fn () =>
    Test.assertEqual (IntMulOps.concatenate [1, 2, 3, 4], 24))

  val () = Test.register "ch10 string concatenate" (fn () =>
    Test.assertEqual (StrOps.concatenate ["a", "b", "c"], "abc"))

  val () = Test.register "ch10 foldMap" (fn () =>
    Test.assertEqual (IntAddOps.foldMap (fn x => x * 2) [1, 2, 3], 12))

  val () = Test.register "ch10 boolean monoids" (fn () =>
    ( Test.assertBool "or true" (OrOps.concatenate [false, false, true])
    ; Test.assertBool "or empty false" (not (OrOps.concatenate []))
    ; Test.assertBool "and true" (AndOps.concatenate [true, true, true])
    ; Test.assertBool "and empty true" (AndOps.concatenate [])
    ))

  val () = Test.register "ch10 empty is identity" (fn () =>
    ( Test.assertEqual (IntAdd.combine (IntAdd.empty, 5), 5)
    ; Test.assertEqual (IntAdd.combine (5, IntAdd.empty), 5)
    ))
end
