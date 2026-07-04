(* 標準ライブラリの実装: {{:https://ocaml.org/manual/5.4/api/Option.html}[Stdlib.Option]} *)

(* [list.ml]とは異なり、全く同じコンストラクタを定義している。
   しかし、OCamlではshadowingされるため、モジュール内でユーザー定義のコンストラクタが使える。
 *)

type +'a t = Some of 'a | None

(* Exercise 4.1: 以下の関数 [map], [get_or_else], [flat_map], [or_else], [filter] を実装せよ。 *)

let map (f : 'a -> 'b) : 'a t -> 'b t = function
  | None -> None
  | Some x -> Some (f x)

(** [get_or_else default o] は [o] が [Some v] なら [v] を、[None] なら [default] を返す。
    Scala版と異なり、このシグネチャでは[default]が正格評価される点に注意。 *)
let get_or_else (default : 'a) : 'a t -> 'a = function
  | None -> default
  | Some x -> x

(* [default]を[unit -> 'a t]に変更することで遅延評価とする。
   このような遅延評価にした引数のことを thunk と呼ぶ。 *)
let get_or_else_thunk (default : unit -> 'a) : 'a t -> 'a = function
  | None -> default ()
  | Some x -> x

let flat_map (f : 'a -> 'b t) : 'a t -> 'b t = function
  | None -> None
  | Some x -> f x

(** [or_else other o] は [o] が [Some _] ならそのまま返し、[None] なら [other] を返す。
    Scala版と異なり、このシグネチャでは[other]が正格評価される点に注意。 *)
let or_else (other : 'a t) : 'a t -> 'a t = function
  | None -> other
  | some -> some

(** Additional: [or_else]の遅延評価バージョンを実装せよ。 *)
let or_else_thunk (_other : unit -> 'a t) : 'a t -> 'a t = function
  | _ -> failwith "Not implemented"

let filter (p : 'a -> bool) : 'a t -> 'a t = function
  | Some x when p x -> Some x
  | _ -> None

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
let variance (xs : float list) : float t =
  mean xs
  |> flat_map (fun m -> xs |> List.map (fun x -> Float.pow (x -. m) 2.) |> mean)

(** Exercise 4.3: 2つの[Option]値がともに[Some]なら、2つの値に関数[f]を適用する関数[map2]を定義せよ。
    どちらかが[None]なら結果も[None]になる。 *)
let map2 (f : 'a -> 'b -> 'c) (oa : 'a t) (ob : 'b t) : 'c t =
  match (oa, ob) with
  (* OCaml においてペアは , によって構築される。文法としては括弧不要なことが特徴的。
     特に、パターンマッチの左辺では括弧を省略することも多い。 *)
  | Some a, Some b -> Some (f a b)
  | _ -> None

(** Exercise 4.4: OptionのリストをリストのOptionに変換する関数[sequence]を定義せよ。 *)
let rec sequence : 'a t list -> 'a list t = function
  | [] -> Some []
  (* OCaml における List の構築子 (::) は関数や演算子ではないので引数に直接指定できない。
     つまり、[map2 (::) h @@ sequence t]のような記述は出来ない。 *)
  | h :: t -> map2 List.cons h @@ sequence t

(** fold_rightを用いた[sequence]の実装。OCamlの型推論は非常に強力なため、型注釈なしでも十分に動作する。 *)
let sequence_1 os = List.fold_right (map2 List.cons) os (Some [])

(** Exercise 4.5: リストの各要素に関数[f]を適用した結果のリストを[Option]値で返す関数[traverse]を定義せよ。 *)
let traverse (f : 'a -> 'b t) (xs : 'a list) : 'b list t =
  sequence @@ List.map f xs

(** [traverse]を用いた[sequence]の派生実装。 *)
let sequence_via_traverse os = traverse Fun.id os
