(* 第3章 解答例 (MyList)． *)
structure MyList: MY_LIST =
struct
  datatype 'a t = Nil | Cons of 'a * 'a t

  fun fromList xs =
    List.foldr (fn (x, acc) => Cons (x, acc)) Nil xs

  fun toList Nil = []
    | toList (Cons (x, xs)) = x :: toList xs

  exception Empty

  fun tail Nil = raise Empty
    | tail (Cons (_, xs)) = xs

  fun setHead x Nil = raise Empty
    | setHead x (Cons (_, xs)) = Cons (x, xs)

  fun drop n xs =
    if n <= 0 then
      xs
    else
      case xs of
        Nil => Nil
      | Cons (_, rest) => drop (n - 1) rest

  fun dropWhile p Nil = Nil
    | dropWhile p (xs as Cons (x, rest)) =
        if p x then dropWhile p rest else xs

  fun init Nil = raise Empty
    | init (Cons (_, Nil)) = Nil
    | init (Cons (x, rest)) =
        Cons (x, init rest)

  fun foldRight Nil z _ = z
    | foldRight (Cons (x, xs)) z f =
        f (x, foldRight xs z f)

  fun foldLeft xs z f =
    let
      fun go (acc, Nil) = acc
        | go (acc, Cons (x, rest)) =
            go (f (x, acc), rest)
    in
      go (z, xs)
    end

  fun length xs =
    foldLeft xs 0 (fn (_, acc) => acc + 1)

  fun sum xs =
    foldLeft xs 0 (op+)

  fun product xs =
    foldLeft xs 1.0 (op*)

  fun reverse xs =
    foldLeft xs Nil (fn (x, acc) => Cons (x, acc))

  fun append xs ys =
    foldRight xs ys (fn (x, acc) => Cons (x, acc))

  fun concat xss =
    foldRight xss Nil (fn (xs, acc) => append xs acc)

  fun map f xs =
    foldRight xs Nil (fn (x, acc) => Cons (f x, acc))

  fun filter p xs =
    foldRight xs Nil (fn (x, acc) => if p x then Cons (x, acc) else acc)

  fun flatMap f xs =
    concat (map f xs)

  fun zipWith f (Cons (x, xs)) (Cons (y, ys)) =
        Cons (f (x, y), zipWith f xs ys)
    | zipWith _ _ _ = Nil

  fun startsWith _ Nil = true
    | startsWith Nil _ = false
    | startsWith (Cons (x, xs)) (Cons (y, ys)) =
        x = y andalso startsWith xs ys

  fun hasSubsequence sup sub =
    case sub of
      Nil => true
    | _ =>
        (case sup of
           Nil => false
         | Cons (_, rest) => startsWith sup sub orelse hasSubsequence rest sub)
end
