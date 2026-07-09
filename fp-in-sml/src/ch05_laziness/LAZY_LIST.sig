(* 第5章 遅延評価: 遅延リスト (本書の Stream)．
 * SML は正格なので，尾 (tail) をサンク `unit -> 'a t` にして遅延を表現する．
 * 頭 (head) は正格にしている (本書のようなメモ化はしない簡易版)． *)
signature LAZY_LIST =
sig
  datatype 'a t = Nil | Cons of 'a * (unit -> 'a t)

  (* Basis list との橋渡し (補助)．toList は全要素を評価する (無限列に使うな)． *)
  val fromList: 'a list -> 'a t
  val toList: 'a t -> 'a list

  val headOption: 'a t -> 'a option
  val take: int -> 'a t -> 'a t
  val drop: int -> 'a t -> 'a t
  val takeWhile: ('a -> bool) -> 'a t -> 'a t
  val exists: ('a -> bool) -> 'a t -> bool
  val forAll: ('a -> bool) -> 'a t -> bool

  val map: ('a -> 'b) -> 'a t -> 'b t
  val filter: ('a -> bool) -> 'a t -> 'a t
  val append: 'a t -> (unit -> 'a t) -> 'a t (* 第2引数は遅延 *)
  val flatMap: ('a -> 'b t) -> 'a t -> 'b t

  (* 無限列 *)
  val constant: 'a -> 'a t
  val from: int -> int t
  val fibs: unit -> int t
  val unfold: 'b -> ('b -> ('a * 'b) option) -> 'a t
end
