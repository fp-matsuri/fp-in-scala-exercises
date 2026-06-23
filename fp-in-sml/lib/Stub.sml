(* 未実装箇所を表すプレースホルダです．
 * 演習 (exercises) では，本体にある Stub.todo () を置き換える形で実装していきます．
 * Test は，例外 `Stub.Todo` を捕捉し，本物の失敗 (FAIL) とは別の未実装 (todo) として表示します． *)
structure Stub =
struct
  exception Todo

  (* Stub.todo () は任意の型に単一化される．
   * 評価されると Todo を投げる． *)
  fun todo () = raise Todo
end
