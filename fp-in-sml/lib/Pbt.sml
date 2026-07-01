(* プロパティベーステストの基盤です．
 *
 * - 第8章で `Gen`/`Prop` を自作するより前から，第3章などの差分テストでランダム入力を生成するために提供します．
 * - 乱数源の `Pbt.Rng` も自己完結で，第6章の演習 `Rng` とは別物です．
 *
 * `'a gen` は乱数状態を受け取って値と次の状態を返す，状態渡しの関数です．
 *)
structure Pbt :>
sig
  type 'a gen

  val int: int gen
  val bool: bool gen
  val char: char gen
  val intRange: int * int -> int gen

  val map: ('a -> 'b) -> 'a gen -> 'b gen
  val bind: 'a gen -> ('a -> 'b gen) -> 'b gen
  val pair: 'a gen * 'b gen -> ('a * 'b) gen
  val list: 'a gen -> 'a list gen

  (* pred を多数の乱入力で試し，最初に偽となった入力を返す．無ければ NONE を返す． *)
  val findCounterexample: 'a gen -> ('a -> bool) -> 'a option
end =
struct
  type seed = Word64.word
  type 'a gen = seed -> 'a * seed

  (* 線形合同法 (Knuth/MMIX の定数) で次の状態へ． *)
  fun step (s: seed) : seed =
    Word64.+ (Word64.* (s, 0w6364136223846793005), 0w1442695040888963407)

  (* 0 .. 2^30-1 の非負整数です．31bit Int でも安全な範囲です． *)
  fun rawNat (s: seed) : int * seed =
    let
      val s' = step s
      val v = Word64.toInt (Word64.andb (Word64.>> (s', 0w34), 0wx3FFFFFFF))
    in
      (v, s')
    end

  (* テストでの算術が既定の Int (MLton は 32bit) を溢れさせないよう小さめの範囲にします． *)
  fun int s =
    let val (v, s') = rawNat s
    in (v mod 2001 - 1000, s')
    end (* [-1000, 1000] *)

  fun bool s =
    let val (v, s') = rawNat s
    in (v mod 2 = 0, s')
    end

  fun intRange (lo, hi) s =
    if hi <= lo then (lo, step s)
    else let val (v, s') = rawNat s in (lo + v mod (hi - lo + 1), s') end

  fun char s =
    let val (v, s') = intRange (97, 122) s
    in (Char.chr v, s')
    end

  fun map f g =
    fn s => let val (a, s') = g s in (f a, s') end

  fun bind g k =
    fn s => let val (a, s') = g s in k a s' end

  fun pair (ga, gb) =
    fn s =>
      let
        val (a, s1) = ga s
        val (b, s2) = gb s1
      in
        ((a, b), s2)
      end

  fun list g =
    fn s =>
      let
        val (n, s0) = intRange (0, 16) s
        fun loop (0, st, acc) = (List.rev acc, st)
          | loop (k, st, acc) =
              let val (x, st') = g st
              in loop (k - 1, st', x :: acc)
              end
      in
        loop (n, s0, [])
      end

  (* 再現性のための固定シードです．MLton の既定 word は 32 bit なので型注釈が必須です． *)
  val initialSeed: seed = 0wx2545F4914F6CDD1D

  fun findCounterexample g pred =
    let
      val numTests = 200
      fun loop (0, _) = NONE
        | loop (k, s) =
            let val (x, s') = g s
            in if pred x then loop (k - 1, s') else SOME x
            end
    in
      loop (numTests, initialSeed)
    end
end
