(* 第14章 テスト (LocalEffects)．参照実装 (挿入ソート) との差分で検証． *)
structure LocalEffectsTest =
struct
  fun showIntList xs =
    "[" ^ String.concatWith "," (List.map Int.toString xs) ^ "]"

  fun insert (x, []) = [x]
    | insert (x, y :: ys) =
        if x <= y then x :: y :: ys else y :: insert (x, ys)
  fun refSort xs =
    List.foldr insert [] xs

  val () = Test.register "ch14 quicksort example" (fn () =>
    Test.assertEqual
      ( LocalEffects.quicksort [3, 1, 4, 1, 5, 9, 2, 6]
      , [1, 1, 2, 3, 4, 5, 6, 9]
      ))

  val () = Test.register "ch14 quicksort empty/singleton" (fn () =>
    ( Test.assertEqual (LocalEffects.quicksort [], [])
    ; Test.assertEqual (LocalEffects.quicksort [42], [42])
    ))

  val () = Test.register "ch14 quicksort matches reference sort" (fn () =>
    Test.forAll showIntList (Pbt.list Pbt.int) (fn xs =>
      LocalEffects.quicksort xs = refSort xs))
end
