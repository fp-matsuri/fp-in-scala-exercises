(* 第6章 一般化した状態モナド State．
 * ('s, 'a) state は「状態 's を受け取り，結果 'a と次状態 's を返す」計算．
 * 中身 (関数) は :> で隠し，run / state で出し入れする．
 * 第6章では独自コンビネータとして実装し，第11章で MONAD シグネチャに接続する． *)
signature STATE =
sig
  type ('s, 'a) state

  val state: ('s -> 'a * 's) -> ('s, 'a) state (* 生成 *)
  val run: ('s, 'a) state -> 's -> 'a * 's (* 実行 *)

  val unit: 'a -> ('s, 'a) state
  val map: ('a -> 'b) -> ('s, 'a) state -> ('s, 'b) state
  val map2: ('a * 'b -> 'c)
            -> ('s, 'a) state
            -> ('s, 'b) state
            -> ('s, 'c) state
  val flatMap: ('a -> ('s, 'b) state) -> ('s, 'a) state -> ('s, 'b) state
  val sequence: ('s, 'a) state list -> ('s, 'a list) state

  val get: ('s, 's) state
  val set: 's -> ('s, unit) state
  val modify: ('s -> 's) -> ('s, unit) state
end
