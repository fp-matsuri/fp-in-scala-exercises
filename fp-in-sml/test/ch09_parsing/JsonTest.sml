(* 第9章 テスト (Json)．json は real を含み等値型でないので独自 eq/show で比較． *)
structure JsonTest =
struct
  open Json

  fun jsonEq (JNull, JNull) = true
    | jsonEq (JBool a, JBool b) = a = b
    | jsonEq (JNumber a, JNumber b) =
        Real.abs (a - b) < 1.0E~9
    | jsonEq (JString a, JString b) = a = b
    | jsonEq (JArray a, JArray b) = ListPair.allEq jsonEq (a, b)
    | jsonEq (JObject a, JObject b) =
        ListPair.allEq
          (fn ((k1, v1), (k2, v2)) => k1 = k2 andalso jsonEq (v1, v2)) (a, b)
    | jsonEq _ = false

  fun jsonShow JNull = "null"
    | jsonShow (JBool b) = Bool.toString b
    | jsonShow (JNumber r) = Real.toString r
    | jsonShow (JString s) = "\"" ^ s ^ "\""
    | jsonShow (JArray xs) =
        "[" ^ String.concatWith "," (List.map jsonShow xs) ^ "]"
    | jsonShow (JObject ps) =
        "{"
        ^
        String.concatWith ","
          (List.map (fn (k, v) => "\"" ^ k ^ "\":" ^ jsonShow v) ps) ^ "}"

  fun checkParse (input, expected) =
    case Json.parse input of
      Parser.Success j =>
        Test.assertEqualBy {eq = jsonEq, show = jsonShow} (j, expected)
    | Parser.Failure m => Test.assertBool ("parse failed: " ^ m) false

  val () = Test.register "ch09 Json scalars" (fn () =>
    ( checkParse ("null", JNull)
    ; checkParse ("true", JBool true)
    ; checkParse ("false", JBool false)
    ; checkParse ("42", JNumber 42.0)
    ; checkParse ("3.14", JNumber 3.14)
    ; checkParse ("\"hello\"", JString "hello")
    ))

  val () = Test.register "ch09 Json with whitespace" (fn () =>
    checkParse ("   true   ", JBool true))

  val () = Test.register "ch09 Json array" (fn () =>
    checkParse ("[1, 2, 3]", JArray [JNumber 1.0, JNumber 2.0, JNumber 3.0]))

  val () = Test.register "ch09 Json nested object" (fn () =>
    checkParse ("{\"a\": 1, \"b\": [true, null]}", JObject
      [("a", JNumber 1.0), ("b", JArray [JBool true, JNull])]))

  val () = Test.register "ch09 Json empty array/object" (fn () =>
    (checkParse ("[]", JArray []); checkParse ("{}", JObject [])))
end
