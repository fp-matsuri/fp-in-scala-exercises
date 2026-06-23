(* 第8章 演習 (Prop)．run / isPassed は補助として提供済み． *)
structure Prop: PROP =
struct
  datatype result = Passed | Falsified of string

  type prop = int -> Rng.rng -> result

  (* Exercise 8.9: forAll / andProp を実装せよ．
   * forAll: n 回 gen から取り出し，述語が偽になったら Falsified (show 反例)． *)
  fun forAll g show pred = Stub.todo ()
  fun andProp (p1, p2) = Stub.todo ()

  fun run p n rng = p n rng

  fun isPassed Passed = true
    | isPassed (Falsified _) = false
end
