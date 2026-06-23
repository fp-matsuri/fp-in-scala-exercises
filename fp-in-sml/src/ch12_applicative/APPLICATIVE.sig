(* 第12章 アプリカティブ (Applicative)．
 * 原始操作は unit と map2．flatMap が無いぶんモナドより弱いが，その代わり
 * 「独立した複数の計算をまとめる」用途に向き，誤りの蓄積などができる．
 * 派生関数 (map / ap / sequence / traverse ...) は functor ApplicativeUtil で生成． *)
signature APPLICATIVE =
sig
  type 'a t
  val unit: 'a -> 'a t
  val map2: ('a * 'b -> 'c) -> 'a t -> 'b t -> 'c t
end
