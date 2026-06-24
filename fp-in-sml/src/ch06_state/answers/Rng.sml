(* 第6章 解答例 (Rng)． *)
structure Rng :> RNG =
struct
  type rng = Word64.word
  type 'a rand = rng -> 'a * rng

  fun simple seed =
    Word64.andb (Word64.fromInt seed, 0wxFFFFFFFFFFFF)

  (* 線形合同法 (java.util.Random と同じ定数) で次の状態と値を得る． *)
  fun nextInt r =
    let
      val r' = Word64.andb
        (Word64.+ (Word64.* (r, 0wx5DEECE66D), 0wxB), 0wxFFFFFFFFFFFF)
      val hi = Word32.fromLarge (Word64.toLarge (Word64.>> (r', 0w16)))
    in
      (Word32.toIntX hi, r')
    end

  (* 最小値は符号反転できないので ~(n + 1) で非負側へ折り返す． *)
  fun nonNegativeInt r =
    let val (n, r') = nextInt r
    in (if n < 0 then ~(n + 1) else n, r')
    end

  fun double r =
    let val (n, r') = nonNegativeInt r
    in (Real.fromInt n / 2147483648.0, r')
    end

  fun unit a = fn r => (a, r)

  fun map f ra =
    fn r => let val (a, r') = ra r in (f a, r') end

  fun flatMap g ra =
    fn r => let val (a, r') = ra r in g a r' end

  fun map2 f ra rb =
    flatMap (fn a => map (fn b => f (a, b)) rb) ra

  fun sequence rs =
    List.foldr (fn (ra, acc) => map2 (op::) ra acc) (unit []) rs

  fun ints n =
    sequence (List.tabulate (n, fn _ => nonNegativeInt))
end
