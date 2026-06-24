(* 第4章 解答例 (Either)． *)
structure Either: EITHER =
struct
  datatype ('e, 'a) t = Left of 'e | Right of 'a

  fun map f (Right a) =
        Right (f a)
    | map f (Left e) = Left e

  fun flatMap f (Right a) = f a
    | flatMap f (Left e) = Left e

  fun orElse (Left _) other = other
    | orElse right _ = right

  fun map2 f ea eb =
    flatMap (fn a => map (fn b => f (a, b)) eb) ea

  fun traverse f xs =
    List.foldr (fn (x, acc) => map2 (op::) (f x) acc) (Right []) xs

  fun sequence es =
    traverse (fn x => x) es
end
