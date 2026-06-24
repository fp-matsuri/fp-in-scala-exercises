(* 第4章 テスト (Either)．(string, int) t は等値型なので assertEqual が使える． *)
structure EitherTest =
struct
  open Either

  val () = Test.register "ch04 Either.map" (fn () =>
    ( Test.assertEqual
        (map (fn x => x + 1) (Right 1), Right 2 : (string, int) t)
    ; Test.assertEqual
        (map (fn x => x + 1) (Left "e"), Left "e" : (string, int) t)
    ))

  val () = Test.register "ch04 Either.flatMap" (fn () =>
    ( Test.assertEqual
        (flatMap (fn x => Right (x * 2)) (Right 3), Right 6 : (string, int) t)
    ; Test.assertEqual
        (flatMap (fn x => Right (x * 2)) (Left "e"), Left "e" : (string, int) t)
    ))

  val () = Test.register "ch04 Either.orElse" (fn () =>
    ( Test.assertEqual (orElse (Left "e") (Right 9), Right 9 : (string, int) t)
    ; Test.assertEqual (orElse (Right 1) (Right 9), Right 1 : (string, int) t)
    ))

  val () = Test.register "ch04 Either.map2" (fn () =>
    ( Test.assertEqual
        (map2 (op+) (Right 3) (Right 4), Right 7 : (string, int) t)
    ; Test.assertEqual
        (map2 (op+) (Right 3) (Left "e"), Left "e" : (string, int) t)
    ))

  val () = Test.register "ch04 Either.sequence/traverse" (fn () =>
    ( Test.assertEqual
        ( sequence [Right 1, Right 2, Right 3]
        , Right [1, 2, 3] : (string, int list) t
        )
    ; Test.assertEqual
        ( sequence [Right 1, Left "boom", Right 3]
        , Left "boom" : (string, int list) t
        )
    ; Test.assertEqual
        ( traverse (fn x => if x >= 0 then Right x else Left "neg") [1, 2, 3]
        , Right [1, 2, 3] : (string, int list) t
        )
    ; Test.assertEqual
        ( traverse (fn x => if x >= 0 then Right x else Left "neg") [1, ~2, 3]
        , Left "neg" : (string, int list) t
        )
    ))
end
