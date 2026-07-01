(* 第15章 ストリーム処理: 単純なトランスデューサ Process[I,O]．
 * 入力 'i を順に受け取り ('o を Emit しながら) 変換していく状態機械．
 *   Halt              … これ以上出力しない
 *   Emit (o, rest)    … o を1つ出し，続きは rest
 *   Await recv        … 次の入力 (NONE は入力終端) を待ち，recv で続きを決める
 * apply で入力リストを流し込み，出力リストを得る． *)
signature PROCESS =
sig
  datatype ('i, 'o) process =
    Halt
  | Emit of 'o * ('i, 'o) process
  | Await of 'i option -> ('i, 'o) process

  val apply: ('i, 'o) process -> 'i list -> 'o list

  val lift: ('i -> 'o) -> ('i, 'o) process
  val filter: ('i -> bool) -> ('i, 'i) process
  val take: int -> ('i, 'i) process
  val sum: (real, real) process (* 累積和 *)
  val count: ('i, int) process (* 累積個数 *)

  (* p1 を通してから p2 に流す合成 (本書の |>)． *)
  val pipe: ('i, 'o) process -> ('o, 'p) process -> ('i, 'p) process
end
