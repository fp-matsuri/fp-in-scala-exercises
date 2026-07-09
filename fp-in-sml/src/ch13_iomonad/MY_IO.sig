(* 第13章 IO モナド: 副作用を「記述」として値にし，run するまで実行を遅らせる．
 * 'a io の中身 (unit -> 'a のサンク) は :> で隠す．
 * effect で任意の副作用を IO に持ち上げ，run で実際に走らせる． *)
signature MY_IO =
sig
  type 'a io

  val unit: 'a -> 'a io
  val flatMap: ('a -> 'b io) -> 'a io -> 'b io
  val map: ('a -> 'b) -> 'a io -> 'b io
  val sequence: 'a io list -> 'a list io

  val effect: (unit -> 'a) -> 'a io (* 副作用を IO に持ち上げる *)
  val run: 'a io -> 'a (* 効果を実行する *)
end
