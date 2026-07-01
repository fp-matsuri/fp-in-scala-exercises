(* 第13章 解答例 (MyIO)． *)
structure MyIO :> MY_IO =
struct
  (* 「実行すると 'a を返す遅延計算」をサンク unit -> 'a で表す． *)
  type 'a io = unit -> 'a

  (* effect/run は封印した型の出入り口 (中身はサンクそのもの)． *)
  fun effect th = th
  fun run m = m ()

  fun unit a () = a

  fun flatMap f m () =
    run (f (run m))

  fun map f m () =
    f (run m)

  (* 効果が左から右の順に走るよう，モナド的に合成する． *)
  fun sequence ms =
    List.foldr (fn (m, acc) => flatMap (fn x => map (fn xs => x :: xs) acc) m)
      (unit []) ms
end
