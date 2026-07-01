(* 第8章 演習 (Gen)．sample は補助として提供済み． *)
structure Gen: GEN =
struct
  type 'a gen = 'a Rng.rand

  fun sample g rng = g rng

  (* Exercise 8.4-8.13: 以下を実装せよ．Rng のコンビネータを使ってよい． *)
  fun unit a = Stub.todo ()
  fun boolean r = Stub.todo ()
  fun choose (start, stopExclusive) = Stub.todo ()

  fun map f g = Stub.todo ()
  fun map2 f ga gb = Stub.todo ()
  fun flatMap f g = Stub.todo ()

  fun listOfN n g = Stub.todo ()
  fun listOf g = Stub.todo ()
  fun pair ga gb = Stub.todo ()
  fun union ga gb = Stub.todo ()
end
