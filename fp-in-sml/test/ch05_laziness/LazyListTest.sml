(* 第5章 テスト (LazyList)．無限列は take してから toList で確かめる． *)
structure LazyListTest =
struct
  structure L = LazyList

  fun showIntList xs =
    "[" ^ String.concatWith "," (List.map Int.toString xs) ^ "]"

  val intList = Pbt.list Pbt.int

  val () = Test.register "ch05 LazyList.toList/fromList round trip" (fn () =>
    Test.forAll showIntList intList (fn xs => L.toList (L.fromList xs) = xs))

  val () = Test.register "ch05 LazyList.take" (fn () =>
    Test.assertEqual
      (L.toList (L.take 3 (L.fromList [1, 2, 3, 4, 5])), [1, 2, 3]))

  val () = Test.register "ch05 LazyList.drop" (fn () =>
    Test.assertEqual
      (L.toList (L.drop 2 (L.fromList [1, 2, 3, 4, 5])), [3, 4, 5]))

  val () = Test.register "ch05 LazyList.takeWhile" (fn () =>
    Test.assertEqual
      (L.toList (L.takeWhile (fn x => x < 3) (L.fromList [1, 2, 3, 1])), [1, 2]))

  val () = Test.register "ch05 LazyList.headOption" (fn () =>
    ( Test.assertEqual (L.headOption (L.fromList [9, 8]), SOME 9)
    ; Test.assertEqual (L.headOption (L.fromList ([] : int list)), NONE)
    ))

  val () = Test.register "ch05 LazyList.exists/forAll" (fn () =>
    let
      val s = L.fromList [2, 4, 6]
    in
      Test.assertBool "exists even" (L.exists (fn x => x mod 2 = 0) s);
      Test.assertBool "all even" (L.forAll (fn x => x mod 2 = 0) s);
      Test.assertBool "not all > 4" (not (L.forAll (fn x => x > 4) s))
    end)

  val () = Test.register "ch05 LazyList.map/filter" (fn () =>
    Test.forAll showIntList intList (fn xs =>
      L.toList (L.map (fn x => x + 1) (L.fromList xs))
      = List.map (fn x => x + 1) xs
      andalso
      L.toList (L.filter (fn x => x mod 2 = 0) (L.fromList xs))
      = List.filter (fn x => x mod 2 = 0) xs))

  val () = Test.register "ch05 LazyList.append/flatMap" (fn () =>
    ( Test.assertEqual
        ( L.toList (L.append (L.fromList [1, 2]) (fn () => L.fromList [3, 4]))
        , [1, 2, 3, 4]
        )
    ; Test.assertEqual
        ( L.toList (L.flatMap (fn x => L.fromList [x, x]) (L.fromList [1, 2]))
        , [1, 1, 2, 2]
        )
    ))

  val () = Test.register "ch05 LazyList.constant/from/fibs (infinite)" (fn () =>
    ( Test.assertEqual (L.toList (L.take 4 (L.constant 7)), [7, 7, 7, 7])
    ; Test.assertEqual (L.toList (L.take 5 (L.from 10)), [10, 11, 12, 13, 14])
    ; Test.assertEqual (L.toList (L.take 7 (L.fibs ())), [0, 1, 1, 2, 3, 5, 8])
    ))

  val () = Test.register "ch05 LazyList.unfold" (fn () =>
    Test.assertEqual
      ( L.toList (L.unfold 0 (fn n =>
          if n < 5 then SOME (n * n, n + 1) else NONE))
      , [0, 1, 4, 9, 16]
      ))
end
