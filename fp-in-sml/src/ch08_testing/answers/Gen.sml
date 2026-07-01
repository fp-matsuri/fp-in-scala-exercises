(* 第8章 解答例 (Gen)．Rng のコンビネータを土台にする． *)
structure Gen: GEN =
struct
  type 'a gen = 'a Rng.rand

  fun sample g rng = g rng

  val unit = Rng.unit

  val boolean = Rng.map (fn n => n mod 2 = 0) Rng.nonNegativeInt

  fun choose (start, stopExclusive) =
    Rng.map (fn n => start + n mod (stopExclusive - start)) Rng.nonNegativeInt

  val map = Rng.map
  val map2 = Rng.map2
  val flatMap = Rng.flatMap

  fun listOfN n g =
    Rng.sequence (List.tabulate (n, fn _ => g))

  fun listOf g =
    flatMap (fn n => listOfN n g) (choose (0, 16))

  fun pair ga gb =
    map2 (fn x => x) ga gb

  fun union ga gb =
    flatMap (fn b => if b then ga else gb) boolean
end
