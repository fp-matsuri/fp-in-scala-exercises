(** 乱数モジュールを一般化して、状態モナドとして定義する。 *)

type ('s, +'a) t = 's -> 'a * 's

(** 状態に実際の値を渡し、実行する。 *)
let run (state : _ t) context = state context

(** 値[a]をそのまま返し、状態を変更しない。 *)
let unit (a : 'a) : ('s, 'a) t = fun s -> (a, s)

(** Exercise 6.10: [map], [map2], [flat_map], [sequence], [traverse] を実装せよ。 *)

let map (_f : 'a -> 'b) (_state : ('s, 'a) t) : ('s, 'b) t =
  failwith "Not implemented"

let map2 (_f : 'a -> 'b -> 'c) (_sa : ('s, 'a) t) (_sb : ('s, 'b) t) :
    ('s, 'c) t =
  failwith "Not implemented"

let flat_map (_f : 'a -> ('s, 'b) t) (_state : ('s, 'a) t) : ('s, 'b) t =
  failwith "Not implemented"

let sequence (_states : ('s, 'a) t list) : ('s, 'a list) t =
  failwith "Not implemented"

let traverse (_f : 'a -> ('s, 'b) t) (_xs : 'a list) : ('s, 'b list) t =
  failwith "Not implemented"

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
