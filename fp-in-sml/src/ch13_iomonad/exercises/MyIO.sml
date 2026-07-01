(* 第13章 演習 (MyIO)．effect / run は提供済み． *)
structure MyIO :> MY_IO =
struct
  type 'a io = unit -> 'a

  fun effect th = th
  fun run m = m ()

  (* Exercise 13.x: unit / flatMap / map / sequence を実装せよ． *)
  fun unit a () = Stub.todo ()
  fun flatMap f m () = Stub.todo ()
  fun map f m () = Stub.todo ()
  fun sequence ms () = Stub.todo ()
end
