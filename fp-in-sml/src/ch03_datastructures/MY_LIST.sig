(* 第3章 関数型データ構造: 単方向リスト．
 * 本書にならい Basis の list ではなく独自の datatype を定義する．
 * fromList / toList は Basis list との橋渡し (テストや REPL 用の補助)． *)
signature MY_LIST =
sig
  datatype 'a t = Nil | Cons of 'a * 'a t

  (* 補助 (演習対象ではない) *)
  val fromList: 'a list -> 'a t
  val toList: 'a t -> 'a list

  val tail: 'a t -> 'a t
  val setHead: 'a -> 'a t -> 'a t
  val drop: int -> 'a t -> 'a t
  val dropWhile: ('a -> bool) -> 'a t -> 'a t
  val init: 'a t -> 'a t

  val length: 'a t -> int
  val foldRight: 'a t -> 'b -> ('a * 'b -> 'b) -> 'b
  val foldLeft: 'a t -> 'b -> ('a * 'b -> 'b) -> 'b

  val sum: int t -> int
  val product: real t -> real
  val reverse: 'a t -> 'a t
  val append: 'a t -> 'a t -> 'a t
  val concat: 'a t t -> 'a t

  val map: ('a -> 'b) -> 'a t -> 'b t
  val filter: ('a -> bool) -> 'a t -> 'a t
  val flatMap: ('a -> 'b t) -> 'a t -> 'b t
  val zipWith: ('a * 'b -> 'c) -> 'a t -> 'b t -> 'c t

  (* sup が sub を部分列として含むか． *)
  val hasSubsequence: ''a t -> ''a t -> bool
end
