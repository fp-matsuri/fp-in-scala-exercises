(* 標準ライブラリの実装: {{:https://ocaml.org/manual/5.4/api/Either.html}[Stdlib.Either]}

   OCaml には {{:https://ocaml.org/manual/5.4/api/Result.html}[Stdlib.Result]} という、Either と同様の型も存在する。
   [Either]には left-biased なのか、right-biased なのか、という問題があり、これは言語や実装による。
   OCaml では [Either] をあくまで中道な型として定義し、正常値が欲しい場合には [Result] を使うことが推奨されている。

   一方で、Scala は right-biased であり、オリジナルに倣って、ここでは right-biased な [Either] を定義することにする。 *)

type (+'e, +'a) t = Left of 'e | Right of 'a

(** Exercise 4.6: [Option]に準じて [map], [flat_map], [or_else], [map2] を実装せよ。 *)

let map (_f : 'a -> 'b) : ('err, 'a) t -> ('err, 'b) t = function
  | _ -> failwith "Not implemented"

let flat_map (_f : 'a -> ('err, 'b) t) : ('err, 'a) t -> ('err, 'b) t = function
  | _ -> failwith "Not implemented"

let or_else (_other : ('err, 'a) t) : ('err, 'a) t -> ('err, 'a) t = function
  | _ -> failwith "Not implemented"

let map2 (_f : 'a -> 'b -> 'c) (_ea : ('err, 'a) t) (_eb : ('err, 'b) t) :
    ('err, 'c) t =
  failwith "Not implemented"

(** Exercise 4.7: [Option]に準じて [traverse], [sequence] を実装せよ。 *)

let rec traverse (_f : 'a -> ('err, 'b) t) : 'a list -> ('err, 'b list) t =
  function
  | _ -> failwith "Not implemented"

let sequence (_es : ('err, 'a) t list) : ('err, 'a list) t =
  failwith "Not implemented"

let mean = function
  | [] -> Left "mean of empty array!"
  | xs ->
      let n = float (List.length xs) in
      Right (List.fold_left ( +. ) 0.0 xs /. n)

let safe_div x y = try Right (x / y) with e -> Left e

(** thunk を引数に使い、任意の関数の例外を Either に変換する。 *)
let catch f = try Right (f ()) with e -> Left e

(* エラーのリストを Left に蓄積する実装 *)

let map2_all (_f : 'a -> 'b -> 'c) (_ea : ('err list, 'a) t)
    (_eb : ('err list, 'b) t) : ('err list, 'c) t =
  failwith "Not implemented"

let rec traverse_all (_f : 'a -> ('err list, 'b) t) :
    'a list -> ('err list, 'b list) t = function
  | _ -> failwith "Not implemented"

let sequence_all (_es : ('err list, 'a) t list) : ('err list, 'a list) t =
  failwith "Not implemented"
