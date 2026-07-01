(* 第11章 モナド: unit と flatMap を持つ型構築子．
 * SML には高階型 (HKT) が無いので，'a t を持つ「モジュール」を MONAD で表し，
 * 派生関数 (map / map2 / sequence ...) は functor MonadUtil で生成する．
 * 注意: ここでの functor は ML のモジュール関数であり，Scala の Functor とは別物． *)
signature MONAD =
sig
  type 'a t
  val unit: 'a -> 'a t
  val flatMap: ('a -> 'b t) -> 'a t -> 'b t
end
