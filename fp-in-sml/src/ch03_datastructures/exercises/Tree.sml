(* 第3章 演習 (Tree)． *)
structure Tree: TREE =
struct
  datatype 'a t = Leaf of 'a | Branch of 'a t * 'a t

  (* Exercise 3.25: 葉と枝の総数を数えよ． *)
  fun size t = Stub.todo ()

  (* Exercise 3.27: 根から葉までの最大の深さを返せ． *)
  fun depth t = Stub.todo ()

  (* Exercise 3.28: 各葉に f を適用せよ． *)
  fun map f t = Stub.todo ()

  (* Exercise 3.29: size / depth / map を一般化する fold を実装せよ． *)
  fun fold g combine t = Stub.todo ()

  (* Exercise 3.26: int の木の最大値を返せ． *)
  fun maximum t = Stub.todo ()
end
