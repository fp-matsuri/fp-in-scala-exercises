(* 第15章 演習 (Process)．apply (駆動部) は提供済み．
 * sum / count は「値」なので，読込時に落ちないよう Await でくるんでおく
 * (実際に駆動されたときに Todo を投げる)． *)
structure Process: PROCESS =
struct
  datatype ('i, 'o) process =
    Halt
  | Emit of 'o * ('i, 'o) process
  | Await of 'i option -> ('i, 'o) process

  fun apply p input =
    case p of
      Halt => []
    | Emit (out, rest) => out :: apply rest input
    | Await recv =>
        (case input of
           [] => apply (recv NONE) []
         | x :: xs => apply (recv (SOME x)) xs)

  (* Exercise 15.x: 以下を実装せよ． *)
  fun lift f = Stub.todo ()
  fun filter p = Stub.todo ()
  fun take n = Stub.todo ()
  val sum = Await (fn _ => Stub.todo ())
  val count = Await (fn _ => Stub.todo ())
  fun pipe p1 p2 = Stub.todo ()
end
