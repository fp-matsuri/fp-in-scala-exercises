(* 第8章 プロパティベーステストの自作: ジェネレータ Gen．
 * 第6章の Rng の上に組み立てる ('a gen は 'a Rng.rand そのもの)．
 * (この Gen は lib/Pbt とは別物で，こちらが「自作版」．) *)
signature GEN =
sig
  type 'a gen = 'a Rng.rand

  val sample: 'a gen -> Rng.rng -> 'a * Rng.rng

  val unit: 'a -> 'a gen
  val boolean: bool gen
  (* [start, stopExclusive) の整数 *)
  val choose: int * int -> int gen

  val map: ('a -> 'b) -> 'a gen -> 'b gen
  val map2: ('a * 'b -> 'c) -> 'a gen -> 'b gen -> 'c gen
  val flatMap: ('a -> 'b gen) -> 'a gen -> 'b gen

  val listOfN: int -> 'a gen -> 'a list gen
  val listOf: 'a gen -> 'a list gen
  val pair: 'a gen -> 'b gen -> ('a * 'b) gen
  val union: 'a gen -> 'a gen -> 'a gen
end
