(* 第2章 関数型プログラミングへの準備．
 * 高階関数・カリー化・関数合成といった基礎を SML で確認する． *)
signature INTRO =
sig
  (* n 番目のフィボナッチ数 (fib 0 = 0, fib 1 = 1)． *)
  val fib: int -> int

  (* 比較関数 ordered に照らして列が昇順かを判定する． *)
  val isSorted: 'a list * ('a * 'a -> bool) -> bool

  (* タプル2引数の関数をカリー化する． *)
  val curry: ('a * 'b -> 'c) -> 'a -> 'b -> 'c

  (* curry の逆． *)
  val uncurry: ('a -> 'b -> 'c) -> 'a * 'b -> 'c

  (* 2つの関数を合成する (compose f g = fn x => f (g x))． *)
  val compose: ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c
end
