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
let to_list (l : 'a t) : 'a list =
  let rec go acc l =
    match l () with Nil -> List.rev acc | Cons (h, t) -> go (h :: acc) t
  in
  go [] l

let[@tail_mod_cons] rec to_list_tmc (l : 'a t) : 'a list =
  match l () with Nil -> [] | Cons (h, t) -> h :: to_list_tmc t

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

let rec take (n : int) (l : 'a t) : 'a t =
  match l () with
  | Cons (h, t) when n > 0 -> cons h @@ lazy (take (n - 1) t)
  | _ -> nil

let rec drop (n : int) (l : 'a t) : 'a t =
  match l () with Cons (_, t) when n > 0 -> drop (n - 1) t | _ -> l

(** Exercise 5.3: 先頭から条件を満たす限り続けて要素を返す[take_while]を定義せよ。 *)
let rec take_while (p : 'a -> bool) (l : 'a t) : 'a t =
  match l () with
  | Cons (h, t) when p h -> cons h @@ lazy (take_while p t)
  | _ -> nil

(** Exercise 5.4: すべての要素が条件を満たすかどうかを判定する[for_all]を定義せよ。 *)
let for_all (p : 'a -> bool) (l : 'a t) : bool =
  fold_right (lazy true) (fun a b -> p a && Lazy.force b) l

(** Exercise 5.5: [fold_right]を用いて[take_while]を実装せよ。 *)
let take_while_via_fold_right (p : 'a -> bool) (l : 'a t) : 'a t =
  fold_right (lazy nil) (fun a b -> if p a then cons a b else nil) l

(** Exercise 5.6: [fold_right]を用いて先頭要素を返す[head_option]を実装せよ。 *)
let head_option (l : 'a t) : 'a option =
  fold_right (lazy None) (fun a _ -> Some a) l

(** Exercise 5.7: [fold_right]を用いて[map], [filter], [append], [flat_map]を実装せよ。 *)

let map (f : 'a -> 'b) (l : 'a t) : 'b t =
  fold_right (lazy nil) (fun a acc -> cons (f a) acc) l

let filter (p : 'a -> bool) (l : 'a t) : 'a t =
  fold_right
    (lazy nil)
    (fun a acc -> if p a then cons a acc else Lazy.force acc)
    l

let append (l : 'a t) (other : 'a t Lazy.t) : 'a t =
  fold_right other (fun a acc -> cons a acc) l

let flat_map (f : 'a -> 'b t) (l : 'a t) : 'b t =
  fold_right (lazy (fun () -> Nil)) (fun a acc -> append (f a) acc) l

(** Exercise 5.8: 任意の値を無限に繰り返す[continually]を定義せよ。 *)
let rec continually (a : 'a) : 'a t = fun () -> Cons (a, continually a)

(** Exercise 5.9: [n]から1ずつ増える無限の遅延リストを生成する[from]を定義せよ。 *)
let rec from (n : int) : int t = fun () -> Cons (n, from (n + 1))

(** Exercise 5.10: フィボナッチ数の無限の遅延リスト[fibs]を定義せよ。 *)
let fibs : int t =
  let rec go current next () = Cons (current, go next (current + next)) in
  go 0 1

(** Exercise 5.11:
    初期状態[state]、状態から次の要素と次の状態を返す関数[f]を受け取って遅延リストを生成する一般的な関数[unfold]を定義せよ。 *)
let rec unfold (state : 's) (f : 's -> ('a * 's) option) : 'a t =
  match f state with Some (a, s) -> cons a @@ lazy (unfold s f) | None -> nil

(** Exercise 5.12: [unfold]を用いて[fibs], [from], [continually], [ones]を再実装せよ。 *)

let fibs_via_unfold : int t =
  unfold (0, 1) (fun (current, next) -> Some (current, (next, current + next)))

let from_via_unfold (n : int) : int t = unfold n (fun n -> Some (n, n + 1))
let continually_via_unfold (a : 'a) : 'a t = unfold () (fun () -> Some (a, ()))
let ones_via_unfold : int t = unfold () (fun () -> Some (1, ()))

(** Exercise 5.13: [unfold]を用いて[map],[take],[takeWhile],[zipWith],[zipAll]を実装せよ。
    [zipAll]は2つの遅延リストが両方とも尽きるまでそれぞれ先頭から順に取り出して対応する要素をペアにして返す。 *)

let map_via_unfold (f : 'a -> 'b) (l : 'a t) : 'b t =
  unfold l @@ fun s ->
  match s () with Cons (h, t) -> Some (f h, t) | Nil -> None

let take_via_unfold (n : int) (l : 'a t) : 'a t =
  unfold (l, n) @@ fun (s, n) ->
  match s () with Cons (h, t) when n > 0 -> Some (h, (t, n - 1)) | _ -> None

let take_while_via_unfold (p : 'a -> bool) (l : 'a t) : 'a t =
  unfold l @@ fun s ->
  match s () with Cons (h, t) when p h -> Some (h, t) | _ -> None

let zip_with (f : 'a -> 'b -> 'c) (l1 : 'a t) (l2 : 'b t) : 'c t =
  unfold (l1, l2) @@ fun (a, b) ->
  match (a (), b ()) with
  | Cons (h1, t1), Cons (h2, t2) -> Some (f h1 h2, (t1, t2))
  | _ -> None

let zip_all (l1 : 'a t) (l2 : 'b t) : ('a option * 'b option) t =
  unfold (l1, l2) @@ fun (a, b) ->
  match (a (), b ()) with
  | Nil, Nil -> None
  | Cons (h1, t1), Nil -> Some ((Some h1, None), (t1, nil))
  | Nil, Cons (h2, t2) -> Some ((None, Some h2), (nil, t2))
  | Cons (h1, t1), Cons (h2, t2) -> Some ((Some h1, Some h2), (t1, t2))

(** Exercise 5.14: 定義済みの関数を用いて、遅延リストが[prefix]で始まるかを判定する [starts_with]を定義せよ。 *)
let starts_with (prefix : 'a t) (l : 'a t) : bool =
  zip_all l prefix
  |> take_while (fun (_, b) -> b <> None)
  |> for_all (fun (a, b) -> a = b)

(** Exercise 5.15: [unfold]を用いて、リストに繰り返し[tail]を適用した結果を返す [tails]を定義せよ。
    例:[of_list [1;2;3] |> tails]は[[[1;2;3]; [2;3]; [3]; []]]に対応する遅延リスト。 *)
let tails (l : 'a t) : 'a t t =
  let body =
    unfold l @@ fun s ->
    match s () with Nil -> None | Cons (_, t) -> Some (s, t)
  in
  append body (lazy (cons nil @@ lazy nil))

(** Exercise 5.16:
    [tails]を一般化して、[fold_right]の累積値を要素とする遅延リストを返す[scan_right]を定義せよ。 *)
let scan_right (z : 'b) (f : 'a -> 'b Lazy.t -> 'b) (l : 'a t) : 'b t =
  fold_right
    (lazy (z, cons z @@ lazy nil))
    (fun a b ->
      let b1, b2 = Lazy.force b in
      let b = f a @@ lazy b1 in
      (b, cons b @@ lazy b2))
    l
  |> snd (* ペアの2つ目をとる *)
