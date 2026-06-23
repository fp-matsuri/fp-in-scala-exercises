(* 第10章 モノイド: 結合的な二項演算 combine と単位元 empty を持つ型．
 * 法則: combine が結合的で，empty が左右の単位元． *)
signature MONOID =
sig
  type m
  val empty: m
  val combine: m * m -> m
end
