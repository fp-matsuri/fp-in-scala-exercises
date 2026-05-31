(* 標準ライブラリの実装: {{:https://ocaml.org/manual/5.4/api/Seq.html}[Stdlib.Seq]} *)

(* thunk により遅延リストを実現している。
   また、OCaml では [and] を使うと相互再帰的な型を書ける。
 *)
type 'a t = unit -> 'a node
and 'a node = Nil | Cons of 'a * 'a t

let nil () = Nil
let cons h t () = Cons (h, Lazy.force t)
let rec of_list = function [] -> nil | h :: t -> cons h @@ lazy (of_list t)
let rec ones () = Cons (1, ones)

(** Exercise 5.1: 遅延リストを通常のリストに変換する関数[to_list]を定義せよ。 *)
let to_list (_l : 'a t) : 'a list = failwith "Not implemented"

let rec fold_right (z : 'b Lazy.t) (f : 'a -> 'b Lazy.t -> 'b) (l : 'a t) : 'b =
  (* 評価する (= unit を渡して関数呼び出しする) ことで実際の値を得る *)
  match l () with
  (* 空の場合は累積値 z を評価する ([Lazy.force]) *)
  | Nil -> Lazy.force z
  (* [lazy] は [Lazy.t] な値を作成する予約語。
     @see <https://ocaml.org/manual/5.4/coreexamples.html#s%3Alazy-expr> Lazy expression
   *)
  | Cons (h, t) -> f h @@ lazy (fold_right z f t)

let rec find p l =
  match l () with
  | Nil -> None
  | Cons (h, _) when p h -> Some h
  | Cons (_, t) -> find p t

(** Exercise 5.2: 先頭から最初の[n]要素を返す[take]、 先頭から最初の[n]要素をスキップする[drop]を定義せよ。 *)

let rec take (_n : int) (_l : 'a t) : 'a t = failwith "Not implemented"
let rec drop (_n : int) (_l : 'a t) : 'a t = failwith "Not implemented"

(** Exercise 5.3: 先頭から条件を満たす限り続けて要素を返す[take_while]を定義せよ。 *)
let rec take_while (_p : 'a -> bool) (_l : 'a t) : 'a t =
  failwith "Not implemented"

(** Exercise 5.4: すべての要素が条件を満たすかどうかを判定する[for_all]を定義せよ。 *)
let for_all (_p : 'a -> bool) (_l : 'a t) : bool = failwith "Not implemented"

(** Exercise 5.5: [fold_right]を用いて[take_while]を実装せよ。 *)
let take_while_via_fold_right (_p : 'a -> bool) (_l : 'a t) : 'a t =
  failwith "Not implemented"

(** Exercise 5.6: [fold_right]を用いて先頭要素を返す[head_option]を実装せよ。 *)
let head_option (_l : 'a t) : 'a option = failwith "Not implemented"

(** Exercise 5.7: [fold_right]を用いて[map], [filter], [append], [flat_map]を実装せよ。 *)

let map (_f : 'a -> 'b) (_l : 'a t) : 'b t = failwith "Not implemented"
let filter (_p : 'a -> bool) (_l : 'a t) : 'a t = failwith "Not implemented"

let append (_l : 'a t) (_other : 'a t Lazy.t) : 'a t =
  failwith "Not implemented"

let flat_map (_f : 'a -> 'b t) (_l : 'a t) : 'b t = failwith "Not implemented"

(** Exercise 5.8: 任意の値を無限に繰り返す[continually]を定義せよ。 *)
let rec continually (_a : 'a) : 'a t = failwith "Not implemented"

(** Exercise 5.9: [n]から1ずつ増える無限の遅延リストを生成する[from]を定義せよ。 *)
let rec from (_n : int) : int t = failwith "Not implemented"

(** Exercise 5.10: フィボナッチ数の無限の遅延リスト[fibs]を定義せよ。 *)
let fibs : int t = fun () -> failwith "Not implemented"

(** Exercise 5.11:
    初期状態[state]、状態から次の要素と次の状態を返す関数[f]を受け取って遅延リストを生成する一般的な関数[unfold]を定義せよ。 *)
let rec unfold (_state : 's) (_f : 's -> ('a * 's) option) : 'a t =
  failwith "Not implemented"

(** Exercise 5.12: [unfold]を用いて[fibs], [from], [continually], [ones]を再実装せよ。 *)

let fibs_via_unfold : int t = fun () -> failwith "Not implemented"
let from_via_unfold (_n : int) : int t = failwith "Not implemented"
let continually_via_unfold (_a : 'a) : 'a t = failwith "Not implemented"
let ones_via_unfold : int t = fun () -> failwith "Not implemented"

(** Exercise 5.13: [unfold]を用いて[map],[take],[takeWhile],[zipWith],[zipAll]を実装せよ。
    [zipAll]は2つの遅延リストが両方とも尽きるまでそれぞれ先頭から順に取り出して対応する要素をペアにして返す。 *)

let map_via_unfold (_f : 'a -> 'b) (_l : 'a t) : 'b t =
  failwith "Not implemented"

let take_via_unfold (_n : int) (_l : 'a t) : 'a t = failwith "Not implemented"

let take_while_via_unfold (_p : 'a -> bool) (_l : 'a t) : 'a t =
  failwith "Not implemented"

let zip_with (_f : 'a -> 'b -> 'c) (_l1 : 'a t) (_l2 : 'b t) : 'c t =
  failwith "Not implemented"

let zip_all (_l1 : 'a t) (_l2 : 'b t) : ('a option * 'b option) t =
  failwith "Not implemented"

(** Exercise 5.14: 定義済みの関数を用いて、遅延リストが[prefix]で始まるかを判定する [starts_with]を定義せよ。 *)
let starts_with (_prefix : 'a t) (_l : 'a t) : bool = failwith "Not implemented"

(** Exercise 5.15: [unfold]を用いて、リストに繰り返し[tail]を適用した結果を返す [tails]を定義せよ。
    例:[of_list [1;2;3] |> tails]は[[[1;2;3]; [2;3]; [3]; []]]に対応する遅延リスト。 *)
let tails (_l : 'a t) : 'a t t = failwith "Not implemented"

(** Exercise 5.16:
    [tails]を一般化して、[fold_right]の累積値を要素とする遅延リストを返す[scan_right]を定義せよ。 *)
let scan_right (_z : 'b) (_f : 'a -> 'b Lazy.t -> 'b) (_l : 'a t) : 'b t =
  failwith "Not implemented"
