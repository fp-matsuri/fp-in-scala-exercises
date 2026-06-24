(* 第6章 演習 (State)．state / run は提供済み．
 * get は値だが，多相のまま保つため無名関数 (値) として書いてある． *)
structure State :> STATE =
struct
  type ('s, 'a) state = 's -> 'a * 's

  fun state f = f
  fun run st s = st s

  (* Exercise 6.10: unit / map / map2 / flatMap / sequence を実装せよ． *)
  fun unit a = fn s => Stub.todo ()
  fun map f st = fn s => Stub.todo ()
  fun map2 f sa sb = fn s => Stub.todo ()
  fun flatMap g st = fn s => Stub.todo ()
  fun sequence sts = fn s => Stub.todo ()

  (* get / set / modify を実装せよ． *)
  val get = fn s => Stub.todo ()
  fun set s = fn s' => Stub.todo ()
  fun modify f = fn s => Stub.todo ()
end
