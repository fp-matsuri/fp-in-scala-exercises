(* 第3章 テスト (Tree)． *)
structure TreeTest =
struct
  open Tree

  (* (1 (2 3)) のような木 *)
  val t = Branch (Leaf 1, Branch (Leaf 2, Leaf 3))

  val () = Test.register "ch03 Tree.size" (fn () =>
    Test.assertEqual (size t, 5))

  val () = Test.register "ch03 Tree.depth" (fn () =>
    Test.assertEqual (depth t, 2))

  val () = Test.register "ch03 Tree.maximum" (fn () =>
    Test.assertEqual (maximum t, 3))

  val () = Test.register "ch03 Tree.map" (fn () =>
    Test.assertEqual (map (fn x => x * 10) t, Branch
      (Leaf 10, Branch (Leaf 20, Leaf 30))))

  val () = Test.register "ch03 Tree.fold size == map then size" (fn () =>
    Test.assertEqual (size (map (fn x => x + 1) t), size t))
end
