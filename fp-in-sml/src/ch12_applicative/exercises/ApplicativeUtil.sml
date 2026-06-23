(* 第12章 演習 (ApplicativeUtil)．
 * unit と map2 だけから派生関数を導く functor． *)
functor ApplicativeUtil(A: APPLICATIVE) =
struct
  open A

  (* Exercise 12.x: unit / map2 だけを使って実装せよ． *)
  fun map f m = Stub.todo ()
  fun ap fab fa = Stub.todo ()
  fun product (fa, fb) = Stub.todo ()
  fun sequence ms = Stub.todo ()
  fun traverse f xs = Stub.todo ()
  fun replicateM n m = Stub.todo ()
end
