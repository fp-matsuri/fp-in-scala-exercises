(* 第12章 解答例 (ApplicativeUtil)．
 * unit と map2 だけを持つ APPLICATIVE から，map や ap をファンクタで導出する． *)
functor ApplicativeUtil(A: APPLICATIVE) =
struct
  open A

  fun map f m =
    map2 (fn (a, _) => f a) m (unit ())

  fun ap fab fa =
    map2 (fn (g, a) => g a) fab fa

  fun product (fa, fb) =
    map2 (fn x => x) fa fb

  fun sequence ms =
    List.foldr (fn (m, acc) => map2 (fn (x, xs) => x :: xs) m acc) (unit []) ms

  fun traverse f xs =
    sequence (List.map f xs)

  fun replicateM n m =
    sequence (List.tabulate (n, fn _ => m))
end
