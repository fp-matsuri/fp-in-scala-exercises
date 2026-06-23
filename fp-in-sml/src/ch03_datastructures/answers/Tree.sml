(* 第3章 解答例 (Tree)． *)
structure Tree: TREE =
struct
  datatype 'a t = Leaf of 'a | Branch of 'a t * 'a t

  fun fold g combine (Leaf a) = g a
    | fold g combine (Branch (l, r)) =
        combine (fold g combine l, fold g combine r)

  (* size/depth/map/maximum はすべて fold だけで表せる． *)
  fun size t =
    fold (fn _ => 1) (fn (l, r) => 1 + l + r) t

  fun depth t =
    fold (fn _ => 0) (fn (l, r) => 1 + Int.max (l, r)) t

  fun map f t =
    fold (fn a => Leaf (f a)) Branch t

  fun maximum t =
    fold (fn a => a) Int.max t
end
