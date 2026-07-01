(* 第3章 二分木．葉に値を持つ Leaf と，左右の部分木を持つ Branch． *)
signature TREE =
sig
  datatype 'a t = Leaf of 'a | Branch of 'a t * 'a t

  val size: 'a t -> int
  val depth: 'a t -> int
  val map: ('a -> 'b) -> 'a t -> 'b t
  (* 葉を g で，枝を combine で畳む一般化． *)
  val fold: ('a -> 'b) -> ('b * 'b -> 'b) -> 'a t -> 'b
  val maximum: int t -> int
end
