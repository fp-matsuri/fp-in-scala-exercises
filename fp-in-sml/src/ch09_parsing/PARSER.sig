(* 第9章 パーサコンビネータ．
 * 'a parser の中身 (入力文字列と位置を受け取り結果か失敗を返す関数) は :> で隠す．
 * 小さな部品 (succeed / char / satisfy ...) を or / many / map2 などで組み上げる．
 * 再帰的な文法 (JSON の値→配列→値…) のために lazy を用意する． *)
signature PARSER =
sig
  type 'a parser
  datatype 'a result = Success of 'a | Failure of string

  val run: 'a parser -> string -> 'a result

  val succeed: 'a -> 'a parser
  val fail: string -> 'a parser
  val satisfy: (char -> bool) -> char parser
  val char: char -> char parser
  val string: string -> string parser

  val map: ('a -> 'b) -> 'a parser -> 'b parser
  val flatMap: ('a -> 'b parser) -> 'a parser -> 'b parser
  val map2: ('a * 'b -> 'c) -> 'a parser -> 'b parser -> 'c parser
  val product: 'a parser * 'b parser -> ('a * 'b) parser
  val or: 'a parser * 'a parser -> 'a parser

  val many: 'a parser -> 'a list parser
  val many1: 'a parser -> 'a list parser
  val listOfN: int -> 'a parser -> 'a list parser
  val sepBy: 'a parser -> 'b parser -> 'a list parser

  (* 再帰文法を組むためのサンク．lazy (fn () => p) で p の評価を実行時まで遅らせる． *)
  val lazy: (unit -> 'a parser) -> 'a parser
end
