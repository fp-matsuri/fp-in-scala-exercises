(* 第6章 演習 (State)．state / run は提供済み． *)
structure State :> STATE =
struct
  type ('s, 'a) state = 's -> 'a * 's

  fun state f = f
  fun run st s = st s

  (* Exercise 6.10: unit / map / map2 / flatMap / sequence を実装せよ． *)
  fun unit a s = Stub.todo ()
  fun map f st s = Stub.todo ()
  fun map2 f sa sb s = Stub.todo ()
  fun flatMap g st s = Stub.todo ()
  fun sequence sts s = Stub.todo ()

  (* get / set / modify を実装せよ． *)
  fun get s = Stub.todo ()
  fun set s s' = Stub.todo ()
  fun modify f s = Stub.todo ()
end
