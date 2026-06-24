(* 第8章 性質 (Prop)．Gen で乱入力を作り，述語を多数回試す．
 * 失敗したら反例 (show 済み文字列) を持つ Falsified を返す． *)
signature PROP =
sig
  datatype result = Passed | Falsified of string

  type prop = int -> Rng.rng -> result (* テスト回数 -> 乱数 -> 結果 *)

  val forAll: 'a Gen.gen -> ('a -> string) -> ('a -> bool) -> prop
  val andProp: prop * prop -> prop
  val run: prop -> int -> Rng.rng -> result
  val isPassed: result -> bool
end
