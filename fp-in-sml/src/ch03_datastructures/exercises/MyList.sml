(* 第3章 演習 (MyList)．
 * fromList / toList は補助なので実装済み．残りの Stub.todo を置き換えていく． *)
structure MyList: MY_LIST =
struct
  datatype 'a t = Nil | Cons of 'a * 'a t

  fun fromList xs =
    List.foldr (fn (x, acc) => Cons (x, acc)) Nil xs

  fun toList Nil = []
    | toList (Cons (x, xs)) = x :: toList xs

  (* Exercise 3.2: 先頭を除いたリストを返せ (空なら例外)． *)
  fun tail xs = Stub.todo ()

  (* Exercise 3.3: 先頭を差し替えたリストを返せ． *)
  fun setHead x xs = Stub.todo ()

  (* Exercise 3.4: 先頭から n 個落とせ． *)
  fun drop n xs = Stub.todo ()

  (* Exercise 3.5: 条件を満たす間だけ先頭から落とせ． *)
  fun dropWhile p xs = Stub.todo ()

  (* Exercise 3.6: 末尾要素を除いたリストを返せ． *)
  fun init xs = Stub.todo ()

  (* Exercise 3.x: foldRight で長さを数えられるよう，まず foldRight を実装せよ． *)
  fun foldRight xs z f = Stub.todo ()

  (* Exercise 3.10: 末尾再帰の foldLeft を実装せよ． *)
  fun foldLeft xs z f = Stub.todo ()

  (* Exercise 3.9: foldRight か foldLeft で長さを数えよ． *)
  fun length xs = Stub.todo ()

  fun sum xs = Stub.todo ()

  fun product xs = Stub.todo ()

  (* Exercise 3.12: reverse を foldLeft で実装せよ． *)
  fun reverse xs = Stub.todo ()

  (* Exercise 3.14: append を fold で実装せよ． *)
  fun append xs ys = Stub.todo ()

  (* Exercise 3.15: リストのリストを連結せよ． *)
  fun concat xss = Stub.todo ()

  (* Exercise 3.18: map を実装せよ． *)
  fun map f xs = Stub.todo ()

  (* Exercise 3.19: filter を実装せよ． *)
  fun filter p xs = Stub.todo ()

  (* Exercise 3.20: flatMap を実装せよ． *)
  fun flatMap f xs = Stub.todo ()

  (* Exercise 3.23: zipWith を実装せよ． *)
  fun zipWith f xs ys = Stub.todo ()

  (* Exercise 3.24: hasSubsequence を実装せよ． *)
  fun hasSubsequence sup sub = Stub.todo ()
end
