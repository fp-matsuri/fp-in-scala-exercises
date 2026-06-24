(* 第10章 解答例 (モノイド)． *)

structure IntAdd: MONOID =
struct
  type m = int
  val empty = 0
  fun combine (a, b) = a + b
end

structure IntMul: MONOID =
struct
  type m = int
  val empty = 1
  fun combine (a, b) = a * b
end

structure StringM: MONOID =
struct
  type m = string
  val empty = ""
  fun combine (a, b) = a ^ b
end

structure BoolOr: MONOID =
struct
  type m = bool
  val empty = false
  fun combine (a, b) = a orelse b
end

structure BoolAnd: MONOID =
struct
  type m = bool
  val empty = true
  fun combine (a, b) = a andalso b
end

functor MonoidOps(M: MONOID) =
struct
  (* foldr で左から右の順序を保つ (combine (a, b) = a ⊕ b のため)． *)
  fun concatenate xs =
    List.foldr M.combine M.empty xs
  fun foldMap f xs =
    concatenate (List.map f xs)
end
