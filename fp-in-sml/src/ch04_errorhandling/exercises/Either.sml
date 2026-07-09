(* 第4章 演習 (Either)． *)
structure Either: EITHER =
struct
  datatype ('e, 'a) t = Left of 'e | Right of 'a

  (* Exercise 4.6: map / flatMap / orElse / map2 を実装せよ．
   * いずれも最初に出会った Left を伝播させる． *)
  fun map f e = Stub.todo ()
  fun flatMap f e = Stub.todo ()
  fun orElse e other = Stub.todo ()
  fun map2 f ea eb = Stub.todo ()

  (* Exercise 4.7: traverse / sequence を実装せよ． *)
  fun traverse f xs = Stub.todo ()
  fun sequence es = Stub.todo ()
end
