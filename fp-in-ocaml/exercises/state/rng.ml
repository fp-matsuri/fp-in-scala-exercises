(** 乱数生成器のモジュール型 *)
module type RNG = sig
  type t
  (** 乱数生成器自体の型。 抽象型のため、外部から実態を参照することは出来ない。 *)

  type 'a rand = t -> 'a * t
  (** 乱数生成のための型。 *)

  val make : int64 -> t
  (** [int64] から乱数生成器を作る *)

  val next_int : t -> int * t
  (** 乱数生成器を基にして、整数の乱数を生成する。 *)
end

module Simple : RNG = struct
  type t = int64
  type 'a rand = t -> 'a * t

  let make = Fun.id

  let next_int seed =
    (* [Int64.t]のための演算子がないので shadowing で置き換える *)
    let ( + ) = Int64.add in
    let ( * ) = Int64.mul in

    (* [land],[lsr]などは文字列だがニ項演算子として使える *)
    let ( land ) = Int64.logand in
    let ( lsr ) = Int64.shift_right_logical in

    let seed = ((seed * 0x5DEECE66DL) + 0xBL) land 0xFFFFFFFFFFFFL in

    (seed lsr 16 |> Int64.to_int, seed)
end

(** ファンクターと呼ばれる機能により、RNGからいくつかの関数を導出する。

    圏論の文脈における関手のファンクターとは全く別物であることに注意。

    ファンクターはモジュールを引数にとり、モジュールを生成する。
    標準ライブラリなどでも、ファンクターによるモジュールの生成は[Make]という名前であることが多い。

    @see <https://ocaml.org/docs/functors> Functors *)
module Make (Rng : RNG) = struct
  include Rng

  let int : int rand = Rng.next_int
  let unit (a : 'a) : 'a rand = fun rng -> (a, rng)

  let map (f : 'a -> 'b) (s : 'a rand) : 'b rand =
   fun rng -> s rng |> Pair.map_fst f

  (** Exercise 6.1: 非負整数をランダム生成する関数[non_negative_int]を実装せよ。 *)
  let non_negative_int (_rng : t) : int * t = failwith "Not implemented"

  (** Exercise 6.2: 0以上1未満の浮動小数点数をランダム生成する関数[double]を実装せよ。 *)
  let double (_rng : t) : float * t = failwith "Not implemented"

  (** Exercise 6.3: 整数と浮動小数点数の組を生成する[int_double], [double_int]、
      浮動小数点数の3つ組を生成する[double3]を実装せよ。 *)

  let int_double (_rng : t) : (int * float) * t = failwith "Not implemented"
  let double_int (_rng : t) : (float * int) * t = failwith "Not implemented"

  let double3 (_rng : t) : (float * float * float) * t =
    failwith "Not implemented"

  (** Exercise 6.4: 引数[count]で指定された要素数の整数リストを生成する[ints]を実装せよ。 *)
  let ints (_count : int) (_rng : t) : int list * t = failwith "Not implemented"

  (** Exercise 6.5: [map]を用いて[double]を再実装せよ。 *)
  let double_via_map (_rng : t) : float * t = failwith "Not implemented"

  (** Exercise 6.6: 2つのRand値を関数[f]で合成する[map2]を実装せよ。 *)
  let map2 (_f : 'a -> 'b -> 'c) (_ra : 'a rand) (_rb : 'b rand) : 'c rand =
    failwith "Not implemented"

  (** Exercise 6.7: Rand値のリストをまとめる[sequence]を実装せよ。 *)
  let sequence (_rs : 'a rand list) : 'a list rand = failwith "Not implemented"

  (** Exercise 6.8: 1つ前の生成結果に依存して次のRand値を構成する[flat_map]を実装せよ。 *)
  let flat_map (_f : 'a -> 'b rand) (_r : 'a rand) : 'b rand =
    failwith "Not implemented"

  (** Exercise 6.9: [flat_map]を用いて[map], [map2]を再実装せよ。 *)

  let map_via_flat_map (_f : 'a -> 'b) (_r : 'a rand) : 'b rand =
    failwith "Not implemented"

  let map2_via_flat_map (_f : 'a -> 'b -> 'c) (_ra : 'a rand) (_rb : 'b rand) :
      'c rand =
    failwith "Not implemented"
end
