(* 第3章 テスト (MyList)．Basis の list/List を参照実装に差分テスト． *)
structure MyListTest =
struct
  fun showIntList xs =
    "[" ^ String.concatWith "," (List.map Int.toString xs) ^ "]"

  fun showPair (xs, ys) =
    "(" ^ showIntList xs ^ ", " ^ showIntList ys ^ ")"

  val intList = Pbt.list Pbt.int
  val pairOfLists = Pbt.pair (intList, intList)

  (* MyList.t を経由した結果 (Basis list) を返す補助 *)
  fun via f xs =
    MyList.toList (f (MyList.fromList xs))

  val () = Test.register "ch03 MyList.length" (fn () =>
    Test.forAll showIntList intList (fn xs =>
      MyList.length (MyList.fromList xs) = List.length xs))

  val () = Test.register "ch03 MyList.reverse" (fn () =>
    Test.forAll showIntList intList (fn xs =>
      via MyList.reverse xs = List.rev xs))

  val () = Test.register "ch03 MyList.map" (fn () =>
    Test.forAll showIntList intList (fn xs =>
      via (MyList.map (fn x => x + 1)) xs = List.map (fn x => x + 1) xs))

  val () = Test.register "ch03 MyList.filter" (fn () =>
    Test.forAll showIntList intList (fn xs =>
      via (MyList.filter (fn x => x mod 2 = 0)) xs
      = List.filter (fn x => x mod 2 = 0) xs))

  val () = Test.register "ch03 MyList.foldLeft" (fn () =>
    Test.forAll showIntList intList (fn xs =>
      MyList.foldLeft (MyList.fromList xs) 0 (fn (x, acc) => x - acc)
      = List.foldl (fn (x, acc) => x - acc) 0 xs))

  val () = Test.register "ch03 MyList.foldRight rebuild" (fn () =>
    Test.forAll showIntList intList (fn xs =>
      let
        val rebuilt =
          MyList.foldRight (MyList.fromList xs) MyList.Nil (fn (x, acc) =>
            MyList.Cons (x, acc))
      in
        MyList.toList rebuilt = xs
      end))

  val () = Test.register "ch03 MyList.append" (fn () =>
    Test.forAll showPair pairOfLists (fn (xs, ys) =>
      MyList.toList (MyList.append (MyList.fromList xs) (MyList.fromList ys))
      = xs @ ys))

  val () = Test.register "ch03 MyList.concat" (fn () =>
    let
      val a = MyList.fromList [1, 2]
      val b = MyList.fromList [3]
      val c = MyList.fromList [4, 5]
      val xss = MyList.fromList [a, b, c]
    in
      Test.assertEqual (MyList.toList (MyList.concat xss), [1, 2, 3, 4, 5])
    end)

  val () = Test.register "ch03 MyList.flatMap" (fn () =>
    let
      val xs = MyList.fromList [1, 2, 3]
      val r = MyList.flatMap (fn x => MyList.fromList [x, x]) xs
    in
      Test.assertEqual (MyList.toList r, [1, 1, 2, 2, 3, 3])
    end)

  val () = Test.register "ch03 MyList.zipWith" (fn () =>
    let
      val r = MyList.zipWith (op+) (MyList.fromList [1, 2, 3])
        (MyList.fromList [10, 20])
    in
      Test.assertEqual (MyList.toList r, [11, 22])
    end)

  val () = Test.register "ch03 MyList.drop/dropWhile/init/tail" (fn () =>
    let
      val xs = MyList.fromList [1, 2, 3, 4]
    in
      Test.assertEqual (MyList.toList (MyList.tail xs), [2, 3, 4]);
      Test.assertEqual (MyList.toList (MyList.setHead 9 xs), [9, 2, 3, 4]);
      Test.assertEqual (MyList.toList (MyList.drop 2 xs), [3, 4]);
      Test.assertEqual
        (MyList.toList (MyList.dropWhile (fn x => x < 3) xs), [3, 4]);
      Test.assertEqual (MyList.toList (MyList.init xs), [1, 2, 3])
    end)

  val () = Test.register "ch03 MyList.sum/product" (fn () =>
    ( Test.assertEqual (MyList.sum (MyList.fromList [1, 2, 3, 4]), 10)
    ; Test.assertEqualBy
        {eq = fn (a, b) => Real.abs (a - b) < 1.0E~9, show = Real.toString}
        (MyList.product (MyList.fromList [2.0, 3.0, 4.0]), 24.0)
    ))

  val () = Test.register "ch03 MyList.hasSubsequence" (fn () =>
    let
      val sup = MyList.fromList [1, 2, 3, 4]
    in
      Test.assertBool "contains [2,3]" (MyList.hasSubsequence sup
        (MyList.fromList [2, 3]));
      Test.assertBool "contains []"
        (MyList.hasSubsequence sup (MyList.fromList []));
      Test.assertBool "not [3,2]" (not (MyList.hasSubsequence sup
        (MyList.fromList [3, 2])))
    end)
end
