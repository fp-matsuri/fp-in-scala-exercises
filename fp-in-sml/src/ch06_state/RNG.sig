(* 第6章 純粋関数型の状態: 擬似乱数生成器 (RNG)．
 * 乱数の「状態」を引き回し，'a rand = rng -> 'a * rng として合成していく．
 * rng の中身 (線形合同法の 48bit 状態) は :> で隠す． *)
signature RNG =
sig
  type rng
  type 'a rand = rng -> 'a * rng

  val simple: int -> rng

  val nextInt: int rand (* 全 32bit 範囲 (負も出る) *)
  val nonNegativeInt: int rand (* 0 以上 *)
  val double: real rand (* [0.0, 1.0) *)

  val unit: 'a -> 'a rand
  val map: ('a -> 'b) -> 'a rand -> 'b rand
  val map2: ('a * 'b -> 'c) -> 'a rand -> 'b rand -> 'c rand
  val flatMap: ('a -> 'b rand) -> 'a rand -> 'b rand
  val sequence: 'a rand list -> 'a list rand
  val ints: int -> int list rand
end
