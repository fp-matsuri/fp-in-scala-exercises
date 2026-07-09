(* 第5章 演習 (LazyList)．fromList / toList は補助なので実装済み． *)
structure LazyList: LAZY_LIST =
struct
  datatype 'a t = Nil | Cons of 'a * (unit -> 'a t)

  fun fromList [] = Nil
    | fromList (x :: xs) =
        Cons (x, fn () => fromList xs)

  fun toList Nil = []
    | toList (Cons (x, tl)) =
        x :: toList (tl ())

  (* Exercise 5.1: headOption を実装せよ． *)
  fun headOption s = Stub.todo ()

  (* Exercise 5.2: take / drop を実装せよ (take は遅延のまま返す)． *)
  fun take n s = Stub.todo ()
  fun drop n s = Stub.todo ()

  (* Exercise 5.3: takeWhile を実装せよ． *)
  fun takeWhile p s = Stub.todo ()

  (* Exercise 5.4: forAll を実装せよ (偽が出たら早く止める)． *)
  fun forAll p s = Stub.todo ()
  fun exists p s = Stub.todo ()

  (* Exercise 5.7: map / filter / append / flatMap を実装せよ (遅延を保つ)． *)
  fun map f s = Stub.todo ()
  fun filter p s = Stub.todo ()
  fun append s1 s2 = Stub.todo ()
  fun flatMap f s = Stub.todo ()

  (* Exercise 5.8-5.11: 無限列． *)
  fun constant a = Stub.todo ()
  fun from n = Stub.todo ()
  fun fibs () = Stub.todo ()
  fun unfold z f = Stub.todo ()
end
