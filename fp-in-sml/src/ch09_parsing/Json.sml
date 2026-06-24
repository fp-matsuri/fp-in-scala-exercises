(* 第9章 JSON パーサ (演習・解答で共通)．
 * Parser の演習を実装すると，このパーサがそのまま動くようになる． *)
structure Json: JSON =
struct
  structure P = Parser

  datatype json =
    JNull
  | JBool of bool
  | JNumber of real
  | JString of string
  | JArray of json list
  | JObject of (string * json) list

  val ws = P.many (P.satisfy Char.isSpace)
  fun lexeme p =
    P.map2 (fn (a, _) => a) p ws
  fun symbol c =
    lexeme (P.char c)
  fun keyword kw =
    lexeme (P.string kw)

  (* open_ p close_ → p の結果だけ取り出す *)
  fun between open_ close_ p =
    P.map2 (fn (x, _) => x) (P.map2 (fn (_, x) => x) open_ p) close_

  fun choice ps =
    List.foldr P.or (P.fail "JSON 値ではない") ps

  val numberP =
    lexeme
      (P.flatMap
         (fn chars =>
            case Real.fromString (String.implode chars) of
              SOME r => P.succeed (JNumber r)
            | NONE => P.fail "数値として解釈できない")
         (P.many1 (P.satisfy (fn c =>
            Char.isDigit c orelse Char.contains "+-.eE" c))))

  (* エスケープ無しの単純な文字列リテラル *)
  val stringRaw =
    between (P.char #"\"") (P.char #"\"")
      (P.map String.implode (P.many (P.satisfy (fn c => c <> #"\""))))

  val jstring = lexeme (P.map JString stringRaw)
  val jnull = P.map (fn _ => JNull) (keyword "null")
  val jbool = P.or
    ( P.map (fn _ => JBool true) (keyword "true")
    , P.map (fn _ => JBool false) (keyword "false")
    )

  fun valueP () =
    choice [jnull, jbool, numberP, jstring, arrayP (), objectP ()]

  and arrayP () =
    P.map JArray (between (symbol #"[") (symbol #"]")
      (P.sepBy (P.lazy valueP) (symbol #",")))

  and pairP () =
    P.map2 (fn (k, v) => (k, v)) (lexeme stringRaw)
      (P.map2 (fn (_, v) => v) (symbol #":") (P.lazy valueP))

  and objectP () =
    P.map JObject (between (symbol #"{") (symbol #"}")
      (P.sepBy (pairP ()) (symbol #",")))

  fun parse s =
    P.run (P.map2 (fn (_, v) => v) ws (valueP ())) s
end
