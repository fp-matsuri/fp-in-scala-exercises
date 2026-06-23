(* 第4章 例外を使わない誤り処理: Option．
 * Basis の option とは別に自作して，Basis を参照実装に比較する．
 * 本書の getOrElse / orElse は引数が名前渡し (遅延) だが，ここでは簡潔さのため
 * 正格 (先に評価) にしている． *)
signature MY_OPTION =
sig
  datatype 'a t = None | Some of 'a

  val map: ('a -> 'b) -> 'a t -> 'b t
  val getOrElse: 'a t -> 'a -> 'a
  val flatMap: ('a -> 'b t) -> 'a t -> 'b t
  val orElse: 'a t -> 'a t -> 'a t
  val filter: ('a -> bool) -> 'a t -> 'a t
  val map2: ('a * 'b -> 'c) -> 'a t -> 'b t -> 'c t
  val sequence: 'a t list -> 'a list t
  val traverse: ('a -> 'b t) -> 'a list -> 'b list t

  (* Basis option との橋渡し (補助) *)
  val toOption: 'a t -> 'a option
  val fromOption: 'a option -> 'a t
end
