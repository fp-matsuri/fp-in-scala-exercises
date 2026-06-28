(* 第10章 演習 (モノイドのインスタンスと派生関数)．
 * 各 empty を正しい単位元に直すこと (combine が未実装のうちはテストは todo 表示のまま)． *)

structure IntAdd: MONOID =
struct
  type m = int
  val empty: int = 0 (* TODO: 正しい単位元に *)
  fun combine (a, b) = Stub.todo ()
end

structure IntMul: MONOID =
struct
  type m = int
  val empty: int = 0 (* TODO: 正しい単位元に *)
  fun combine (a, b) = Stub.todo ()
end

structure StringM: MONOID =
struct
  type m = string
  val empty: string = "" (* TODO: 正しい単位元に *)
  fun combine (a, b) = Stub.todo ()
end

structure BoolOr: MONOID =
struct
  type m = bool
  val empty: bool = false (* TODO: 正しい単位元に *)
  fun combine (a, b) = Stub.todo ()
end

structure BoolAnd: MONOID =
struct
  type m = bool
  val empty: bool = false (* TODO: 正しい単位元に *)
  fun combine (a, b) = Stub.todo ()
end

(* Exercise 10.x: モノイドを使った汎用関数．M をどのインスタンスにも適用できる． *)
functor MonoidOps(M: MONOID) =
struct
  fun concatenate xs = Stub.todo ()
  fun foldMap f xs = Stub.todo ()
end
