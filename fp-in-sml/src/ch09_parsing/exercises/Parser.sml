(* 第9章 演習 (Parser)．
 * 各コンビネータは「パーサ (= fn s => fn i => ...) を返す」形にしてあるので，
 * 本体 Stub.todo () が走るのは実行時 (run された時)．組み立て時には走らない． *)
structure Parser :> PARSER =
struct
  datatype 'a presult = Ok of 'a * int | Err of string
  type 'a parser = string -> int -> 'a presult
  datatype 'a result = Success of 'a | Failure of string

  fun run p s = Stub.todo ()

  (* Exercise 9.x: 以下を実装せよ． *)
  fun succeed a =
    fn s => fn i => Stub.todo ()
  fun fail msg =
    fn s => fn i => Stub.todo ()
  fun satisfy pred =
    fn s => fn i => Stub.todo ()
  fun char c =
    fn s => fn i => Stub.todo ()
  fun string lit =
    fn s => fn i => Stub.todo ()

  fun map f p =
    fn s => fn i => Stub.todo ()
  fun flatMap f p =
    fn s => fn i => Stub.todo ()
  fun map2 f pa pb =
    fn s => fn i => Stub.todo ()
  fun product (pa, pb) =
    fn s => fn i => Stub.todo ()
  fun or (p1, p2) =
    fn s => fn i => Stub.todo ()

  fun many p =
    fn s => fn i => Stub.todo ()
  fun many1 p =
    fn s => fn i => Stub.todo ()
  fun listOfN n p =
    fn s => fn i => Stub.todo ()
  fun sepBy p sep =
    fn s => fn i => Stub.todo ()

  fun lazy thunk =
    fn s => fn i => Stub.todo ()
end
