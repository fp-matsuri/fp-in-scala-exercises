(* 標準ライブラリの実装: {{:https://ocaml.org/manual/5.4/api/Option.html}[Stdlib.Option]} *)

(* [list.ml]とは異なり、全く同じコンストラクタを定義している。
   しかし、OCamlではshadowingされるため、モジュール内でユーザー定義のコンストラクタが使える。
 *)

type +'a t = Some of 'a | None

(* Exercise 4.1: 以下の関数 [map], [get_or_else], [flat_map], [or_else], [filter] を実装せよ。 *)

let map (_f : 'a -> 'b) : 'a t -> 'b t = function
  | _ -> failwith "Not implemented"

(** [get_or_else default o] は [o] が [Some v] なら [v] を、[None] なら [default] を返す。
    Scala版と異なり、このシグネチャでは[default]が正格評価される点に注意。 *)
let get_or_else (_default : 'a) : 'a t -> 'a = function
  | _ -> failwith "Not implemented"

let flat_map (_f : 'a -> 'b t) : 'a t -> 'b t = function
  | _ -> failwith "Not implemented"

(** [or_else other o] は [o] が [Some _] ならそのまま返し、[None] なら [other] を返す。
    Scala版と異なり、このシグネチャでは[other]が正格評価される点に注意。 *)
let or_else (_other : 'a t) : 'a t -> 'a t = function
  | _ -> failwith "Not implemented"

let filter (_p : 'a -> bool) : 'a t -> 'a t = function
  | _ -> failwith "Not implemented"

let failingFn (_i : int) : int =
  let y : int = raise (Failure "fail!") in
  try
    let x = 42 + 5 in
    x + y
  with
  (* 例外に対してのパターンマッチも可能。今回は使用しないので _ で捨てる *)
  | _ ->
    43

let failingFn2 (_i : int) : int =
  try
    let x = 42 + 5 in
    (* [raise] の型は [exn -> 'a] であり、任意の型を指定できる *)
    x + (raise (Failure "fail!") : int)
  with _ -> 43

let failingFn3 (_i : int) : int =
  (* OCaml では try-with だけでなく、match-with でも例外を補足できる *)
  match
    let x = 42 + 5 in
    x + (raise (Failure "fail!") : int)
  with
  | exception _ -> 43
  | v -> v (* match-with は本来パターンマッチの構文なので返ってきた値に対するパターンも必要 *)

(** 浮動小数点数のリストの平均を計算する。空リストなら[None]。 *)
let mean = function
  | [] -> None
  | xs ->
      let n = float (List.length xs) in
      Some (List.fold_left ( +. ) 0.0 xs /. n)

(** Exercise 4.2: 分散(平均からの偏差の2乗の平均)を計算する関数[variance]を定義せよ。 *)
let variance (_xs : float list) : float t = failwith "Not implemented"

(** Exercise 4.3: 2つの[Option]値がともに[Some]なら、2つの値に関数[f]を適用する関数[map2]を定義せよ。
    どちらかが[None]なら結果も[None]になる。 *)
let map2 (_f : 'a -> 'b -> 'c) (_oa : 'a t) (_ob : 'b t) : 'c t =
  failwith "Not implemented"

(** Exercise 4.4: OptionのリストをリストのOptionに変換する関数[sequence]を定義せよ。 *)
let rec sequence : 'a t list -> 'a list t = function
  | _ -> failwith "Not implemented"

(** Exercise 4.5: リストの各要素に関数[f]を適用した結果のリストを[Option]値で返す関数[traverse]を定義せよ。 *)
let traverse (_f : 'a -> 'b t) (_xs : 'a list) : 'b list t =
  failwith "Not implemented"
