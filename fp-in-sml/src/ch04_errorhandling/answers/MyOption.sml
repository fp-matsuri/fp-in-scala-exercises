(* 第4章 解答例 (MyOption)． *)
structure MyOption: MY_OPTION =
struct
  datatype 'a t = None | Some of 'a

  fun toOption None = NONE
    | toOption (Some a) = SOME a

  fun fromOption NONE = None
    | fromOption (SOME a) = Some a

  fun map f None = None
    | map f (Some a) =
        Some (f a)

  fun getOrElse None default = default
    | getOrElse (Some a) _ = a

  fun flatMap f None = None
    | flatMap f (Some a) = f a

  fun orElse None other = other
    | orElse some _ = some

  fun filter p None = None
    | filter p (Some a) =
        if p a then Some a else None

  fun map2 f oa ob =
    flatMap (fn a => map (fn b => f (a, b)) ob) oa

  fun traverse f xs =
    List.foldr (fn (x, acc) => map2 (op::) (f x) acc) (Some []) xs

  fun sequence opts =
    traverse (fn x => x) opts
end
