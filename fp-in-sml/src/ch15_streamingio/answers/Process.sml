(* 第15章 解答例 (Process)． *)
structure Process: PROCESS =
struct
  datatype ('i, 'o) process =
    Halt
  | Emit of 'o * ('i, 'o) process
  | Await of 'i option -> ('i, 'o) process

  fun apply Halt _ = []
    | apply (Emit (out, rest)) input =
        out :: apply rest input
    | apply (Await recv) [] =
        apply (recv NONE) []
    | apply (Await recv) (x :: xs) =
        apply (recv (SOME x)) xs

  fun lift f =
    Await (fn NONE => Halt | SOME x => Emit (f x, lift f))

  fun filter p =
    Await
      (fn NONE => Halt | SOME x => if p x then Emit (x, filter p) else filter p)

  fun take n =
    if n <= 0 then Halt
    else Await (fn NONE => Halt | SOME x => Emit (x, take (n - 1)))

  val sum =
    let
      fun go acc =
        Await
          (fn NONE => Halt | SOME x => let val s = acc + x in Emit (s, go s) end)
    in
      go 0.0
    end

  (* count は入力型 'i に多相．値制限を避けるため，束縛そのものを
   * 構成子適用 Await (...) (非拡張的=一般化できる) にしておく． *)
  fun countFrom n =
    Await (fn NONE => Halt | SOME _ => Emit (n + 1, countFrom (n + 1)))
  val count = Await (fn NONE => Halt | SOME _ => Emit (1, countFrom 1))

  fun pipe p1 p2 =
    case p2 of
      Halt => Halt
    | Emit (out, t2) => Emit (out, pipe p1 t2)
    | Await recv2 =>
        (case p1 of
           Halt => pipe Halt (recv2 NONE)
         | Emit (out, t1) => pipe t1 (recv2 (SOME out))
         | Await recv1 => Await (fn i => pipe (recv1 i) p2))
end
