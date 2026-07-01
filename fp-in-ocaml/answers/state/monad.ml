(** 乱数モジュールを一般化して、状態モナドとして定義する。 *)

type ('s, +'a) t = 's -> 'a * 's

(** 状態に実際の値を渡し、実行する。 *)
let run (state : _ t) context = state context

(** 値[a]をそのまま返し、状態を変更しない。 *)
let unit (a : 'a) : ('s, 'a) t = fun s -> (a, s)

(** Exercise 6.10: [map], [map2], [flat_map], [sequence], [traverse] を実装せよ。 *)

let map (f : 'a -> 'b) (state : ('s, 'a) t) : ('s, 'b) t =
 fun s ->
  let a, s = state s in
  (f a, s)

let map2 (f : 'a -> 'b -> 'c) (sa : ('s, 'a) t) (sb : ('s, 'b) t) : ('s, 'c) t =
 fun s ->
  let a, s = sa s in
  let b, s = sb s in
  (f a b, s)

let flat_map (f : 'a -> ('s, 'b) t) (state : ('s, 'a) t) : ('s, 'b) t =
 fun s ->
  let a, s = state s in
  f a s

let sequence (states : ('s, 'a) t list) : ('s, 'a list) t =
  List.fold_right (map2 List.cons) states (unit [])

let traverse (f : 'a -> ('s, 'b) t) (xs : 'a list) : ('s, 'b list) t =
  List.fold_right (fun a -> map2 List.cons (f a)) xs (unit [])

(** 現在の状態を値として取り出す。 *)
let get : ('s, 's) t = fun s -> (s, s)

(** 状態を[s]に置き換える。 *)
let set (s : 's) : _ t = fun _ -> ((), s)

(** 標準ライブラリにある[Result.Syntax]を模倣した。名前も慣例に従ったもの。

    以下は[either.ml]からの再掲。

    OCaml には Haskell の do notation や Scala の for-comprehension に相当する構文はない。
    しかし、OCamlでは、変数束縛の演算子をユーザーが定義する機能が存在する。
    いわゆるモナドのためのこの記法は、実は、変数束縛こそが重要であると観察できるだろう。

    OCaml では、以下のようにして do notation や for-comprehension と同様の記法を実現できる。

    @see <https://ocaml.org/manual/5.4/bindingops.html> binding operators *)
module Syntax = struct
  let ( let* ) s f = flat_map f s
  let ( let+ ) s f = map f s
end

(** 関数[f]で状態を更新する。 *)
let modify f =
  let open Syntax in
  let* s = get in
  let+ () = set @@ f s in
  ()
