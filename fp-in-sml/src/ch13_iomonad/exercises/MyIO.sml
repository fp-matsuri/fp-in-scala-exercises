(* 第13章 演習 (MyIO)．effect / run は提供済み．
 * モナド操作は「サンク (fn () => ...) を返す」形なので，組み立て時には実行されない． *)
structure MyIO :> MY_IO =
struct
  type 'a io = unit -> 'a

  fun effect th = th
  fun run m = m ()

  (* Exercise 13.x: unit / flatMap / map / sequence を実装せよ． *)
  fun unit a = fn () => Stub.todo ()
  fun flatMap f m = fn () => Stub.todo ()
  fun map f m = fn () => Stub.todo ()
  fun sequence ms = fn () => Stub.todo ()
end
