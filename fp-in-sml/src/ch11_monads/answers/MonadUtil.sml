(* 第11章 解答例 (MonadUtil)．
 * HKT や型クラスが無いので，unit と flatMap だけを持つ MONAD を受け取り，
 * 派生関数 (map/map2/sequence/...) をファンクタで一括生成する． *)
functor MonadUtil(M: MONAD) =
struct
  open M

  fun map f m =
    flatMap (fn a => unit (f a)) m

  fun map2 f ma mb =
    flatMap (fn a => map (fn b => f (a, b)) mb) ma

  fun product (ma, mb) =
    map2 (fn x => x) ma mb

  fun sequence ms =
    List.foldr (fn (m, acc) => map2 (fn (x, xs) => x :: xs) m acc) (unit []) ms

  fun traverse f xs =
    sequence (List.map f xs)

  fun replicateM n m =
    sequence (List.tabulate (n, fn _ => m))

  fun join mma =
    flatMap (fn m => m) mma
end
