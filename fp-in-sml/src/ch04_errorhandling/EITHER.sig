(* 第4章 誤りに理由を付ける: Either．Left が失敗 (理由)，Right が成功． *)
signature EITHER =
sig
  datatype ('e, 'a) t = Left of 'e | Right of 'a

  val map: ('a -> 'b) -> ('e, 'a) t -> ('e, 'b) t
  val flatMap: ('a -> ('e, 'b) t) -> ('e, 'a) t -> ('e, 'b) t
  val orElse: ('e, 'a) t -> ('e, 'a) t -> ('e, 'a) t
  val map2: ('a * 'b -> 'c) -> ('e, 'a) t -> ('e, 'b) t -> ('e, 'c) t
  val sequence: ('e, 'a) t list -> ('e, 'a list) t
  val traverse: ('a -> ('e, 'b) t) -> 'a list -> ('e, 'b list) t
end
