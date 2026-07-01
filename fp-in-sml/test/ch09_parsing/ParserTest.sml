(* 第9章 テスト (Parser)．結果は等値型なので assertEqual が使える． *)
structure ParserTest =
struct
  structure P = Parser

  val () = Test.register "ch09 Parser.char" (fn () =>
    Test.assertEqual (P.run (P.char #"a") "abc", P.Success #"a"))

  val () = Test.register "ch09 Parser.string" (fn () =>
    ( Test.assertEqual (P.run (P.string "ab") "abc", P.Success "ab")
    ; case P.run (P.string "xy") "abc" of
        P.Failure _ => ()
      | P.Success _ => Test.assertBool "should fail" false
    ))

  val () = Test.register "ch09 Parser.or" (fn () =>
    ( Test.assertEqual
        (P.run (P.or (P.string "x", P.string "ab")) "ab", P.Success "ab")
    ; Test.assertEqual
        (P.run (P.or (P.string "ab", P.string "x")) "ab", P.Success "ab")
    ))

  val () = Test.register "ch09 Parser.many" (fn () =>
    Test.assertEqual
      (P.run (P.many (P.char #"a")) "aaab", P.Success [#"a", #"a", #"a"]))

  val () = Test.register "ch09 Parser.many1 fails on zero" (fn () =>
    case P.run (P.many1 (P.char #"a")) "bbb" of
      P.Failure _ => ()
    | P.Success _ => Test.assertBool "should fail" false)

  val () = Test.register "ch09 Parser.map2/product" (fn () =>
    Test.assertEqual
      ( P.run (P.product (P.char #"a", P.char #"b")) "abc"
      , P.Success (#"a", #"b")
      ))

  val () = Test.register "ch09 Parser.satisfy digit" (fn () =>
    Test.assertEqual
      ( P.run (P.many1 (P.satisfy Char.isDigit)) "123x"
      , P.Success [#"1", #"2", #"3"]
      ))

  val () = Test.register "ch09 Parser.sepBy" (fn () =>
    Test.assertEqual
      ( P.run (P.sepBy (P.satisfy Char.isDigit) (P.char #",")) "1,2,3"
      , P.Success [#"1", #"2", #"3"]
      ))

  val () = Test.register "ch09 Parser.listOfN" (fn () =>
    Test.assertEqual
      (P.run (P.listOfN 3 (P.char #"a")) "aaaa", P.Success [#"a", #"a", #"a"]))
end
