(* 第6章 演習 (Rng)．simple / nextInt (乱数エンジン) は提供済み． *)
structure Rng :> RNG =
struct
  type rng = Word64.word
  type 'a rand = rng -> 'a * rng

  fun simple seed =
    Word64.andb (Word64.fromInt seed, 0wxFFFFFFFFFFFF)

  fun nextInt r =
    let
      val r' = Word64.andb
        (Word64.+ (Word64.* (r, 0wx5DEECE66D), 0wxB), 0wxFFFFFFFFFFFF)
      val hi = Word32.fromLarge (Word64.toLarge (Word64.>> (r', 0w16)))
    in
      (Word32.toIntX hi, r')
    end

  (* Exercise 6.1: 0 以上の整数を返せ (Int.minInt に注意)． *)
  fun nonNegativeInt r = Stub.todo ()

  (* Exercise 6.2: [0.0, 1.0) の実数を返せ． *)
  fun double r = Stub.todo ()

  (* Exercise 6.5-6.8: コンビネータを実装せよ． *)
  fun unit a = Stub.todo ()
  fun map f ra = Stub.todo ()
  fun map2 f ra rb = Stub.todo ()
  fun flatMap g ra = Stub.todo ()

  (* Exercise 6.7: rand のリストをまとめる． *)
  fun sequence rs = Stub.todo ()

  (* n 個の nonNegativeInt をまとめる． *)
  fun ints n = Stub.todo ()
end
