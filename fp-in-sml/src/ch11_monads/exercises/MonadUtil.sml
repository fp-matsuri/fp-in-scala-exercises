(* 第11章 演習 (MonadUtil)．
 * unit と flatMap だけから，汎用の派生関数を導く functor．
 * どのモナド M に適用しても map / sequence などが手に入る． *)
functor MonadUtil(M: MONAD) =
struct
  open M

  (* Exercise 11.x: unit / flatMap だけを使って以下を実装せよ． *)
  fun map f m = Stub.todo ()
  fun map2 f ma mb = Stub.todo ()
  fun product (ma, mb) = Stub.todo ()
  fun sequence ms = Stub.todo ()
  fun traverse f xs = Stub.todo ()
  fun replicateM n m = Stub.todo ()
  fun join mma = Stub.todo ()
end
