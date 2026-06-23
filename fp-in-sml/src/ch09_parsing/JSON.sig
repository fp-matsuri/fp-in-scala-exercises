(* 第9章 応用: JSON パーサ．Parser の公開 API だけで組み立てる
 * (Parser の中身には触れない)．エスケープや厳密な数値仕様は簡略化している． *)
signature JSON =
sig
  datatype json =
    JNull
  | JBool of bool
  | JNumber of real
  | JString of string
  | JArray of json list
  | JObject of (string * json) list

  val parse: string -> json Parser.result
end
