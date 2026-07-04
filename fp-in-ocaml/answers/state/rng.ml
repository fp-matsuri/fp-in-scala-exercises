(** 乱数生成器のモジュール型 *)
module type RNG = sig
  type t
  (** 乱数生成器自体の型。 抽象型のため、外部から実態を参照することは出来ない。 *)

  type 'a rand = t -> 'a * t
  (** 乱数生成のための型。 *)

  val make : int64 -> t
  (** [int64] から乱数生成器を作る *)

  val next_int : int rand
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

  let int : int Rng.rand = Rng.next_int
  let unit (a : 'a) : 'a rand = fun rng -> (a, rng)

  let map (f : 'a -> 'b) (s : 'a rand) : 'b rand =
   fun rng -> s rng |> Pair.map_fst f

  (** Exercise 6.1: 非負整数をランダム生成する関数[non_negative_int]を実装せよ。 *)
  let non_negative_int (rng : t) : int * t =
    let n, rng = Rng.next_int rng in
    (* [min_int]の絶対値は[max_int]よりも1大きいので調整する *)
    ((if n < 0 then -succ n else n), rng)

  (** Exercise 6.2: 0以上1未満の浮動小数点数をランダム生成する関数[double]を実装せよ。 *)
  let double (rng : t) : float * t =
    let n, rng = non_negative_int rng in
    (* ゼロ除算を回避するために1を加算する *)
    (float n /. (float max_int +. 1.0), rng)

  (** Exercise 6.3: 整数と浮動小数点数の組を生成する[int_double], [double_int]、
      浮動小数点数の3つ組を生成する[double3]を実装せよ。 *)

  let int_double (rng : t) : (int * float) * t =
    let i, rng = Rng.next_int rng in
    let d, rng = double rng in
    ((i, d), rng)

  let double_int (rng : t) : (float * int) * t =
    int_double rng |> Pair.map_fst Pair.swap

  let double3 (rng : t) : (float * float * float) * t =
    let d1, rng = double rng in
    let d2, rng = double rng in
    let d3, rng = double rng in
    ((d1, d2, d3), rng)

  (** Exercise 6.4: 引数[count]で指定された要素数の整数リストを生成する[ints]を実装せよ。 *)
  let ints (count : int) (rng : t) : int list * t =
    (* 末尾再帰 *)
    let rec go n acc rng =
      if n <= 0 then (acc, rng) (* 生成に対して逆順で返る *)
      else
        let i, rng = Rng.next_int rng in
        go (n - 1) (i :: acc) rng
    in
    go count [] rng

  (** Exercise 6.5: [map]を用いて[double]を再実装せよ。 *)
  let double_via_map (rng : t) : float * t =
    map (fun n -> float n /. (float max_int +. 1.0)) non_negative_int rng

  (** Exercise 6.6: 2つのRand値を関数[f]で合成する[map2]を実装せよ。 *)
  let map2 (f : 'a -> 'b -> 'c) (ra : 'a rand) (rb : 'b rand) : 'c rand =
   fun rng ->
    let a, rng = ra rng in
    let b, rng = rb rng in
    (f a b, rng)

  (** Exercise 6.7: Rand値のリストをまとめる[sequence]を実装せよ。 *)
  let sequence (rs : 'a rand list) : 'a list rand =
    List.fold_right (map2 List.cons) rs (unit [])

  (** Exercise 6.8: 1つ前の生成結果に依存して次のRand値を構成する[flat_map]を実装せよ。 *)
  let flat_map (f : 'a -> 'b rand) (r : 'a rand) : 'b rand =
   fun rng ->
    let a, rng = r rng in
    f a rng

  (** Exercise 6.9: [flat_map]を用いて[map], [map2]を再実装せよ。 *)

  let map_via_flat_map (f : 'a -> 'b) (r : 'a rand) : 'b rand =
    r |> flat_map @@ fun a -> unit @@ f a

  let map2_via_flat_map (f : 'a -> 'b -> 'c) (ra : 'a rand) (rb : 'b rand) :
      'c rand =
    ra |> flat_map @@ fun a -> map_via_flat_map (f a) rb
end

(** OCamlのモジュールはfirst-class objectとして利用できる。

    そのため、値として引数にとることで、functorにせずとも実装できる。

    モジュールの型を参照するために locally abstract type を利用している。

    これは一種のハックで、既にマージされた機能 Modular Explicits で改善される。5.5 から導入される。

    @see <https://ocaml.org/manual/5.4/locallyabstract.html>
      Locally abstract types
    @see <https://ocaml.org/manual/5.4/firstclassmodules.html>
      First-class modules
    @see <https://github.com/ocaml/ocaml/pull/13275> Modular explicits#13275 *)
module First_class_module_examples = struct
  let map (type t) (module Rng : RNG with type t = t) f s rng =
    s rng |> Pair.map_fst f

  let non_negative_int (type t) (module Rng : RNG with type t = t) rng =
    let n, rng = Rng.next_int rng in
    ((if n < 0 then -succ n else n), rng)

  let double (type t) (module Rng : RNG with type t = t) rng =
    let n, rng = non_negative_int (module Rng) rng in
    (float n /. (float max_int +. 1.0), rng)

  let int_double (type t) (module Rng : RNG with type t = t) rng =
    let i, rng = Rng.next_int rng in
    let d, rng = double (module Rng) rng in
    ((i, d), rng)

  let double_int (type t) (module Rng : RNG with type t = t) rng =
    int_double (module Rng) rng |> Pair.map_fst Pair.swap

  let double3 (type t) (module Rng : RNG with type t = t) rng =
    let d1, rng = double (module Rng) rng in
    let d2, rng = double (module Rng) rng in
    let d3, rng = double (module Rng) rng in
    ((d1, d2, d3), rng)

  let ints (type t) (module Rng : RNG with type t = t) count rng =
    let rec go n acc rng =
      if n <= 0 then (acc, rng)
      else
        let i, rng = Rng.next_int rng in
        go (n - 1) (i :: acc) rng
    in
    go count [] rng

  let double_via_map (type t) (module Rng : RNG with type t = t) rng =
    map
      (module Rng)
      (fun n -> float n /. (float max_int +. 1.0))
      (non_negative_int (module Rng))
      rng

  (* 以降の課題は module 指定の意味があまりないので省略 *)
end
