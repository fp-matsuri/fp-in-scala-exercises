(* 第5章 解答例 (LazyList)． *)
structure LazyList: LAZY_LIST =
struct
  datatype 'a t = Nil | Cons of 'a * (unit -> 'a t)

  fun fromList [] = Nil
    | fromList (x :: xs) =
        Cons (x, fn () => fromList xs)

  fun toList Nil = []
    | toList (Cons (x, tl)) =
        x :: toList (tl ())

  fun headOption Nil = NONE
    | headOption (Cons (x, _)) = SOME x

  fun take n s =
    if n <= 0 then
      Nil
    else
      case s of
        Nil => Nil
      | Cons (x, tl) => Cons (x, fn () => take (n - 1) (tl ()))

  fun drop n s =
    if n <= 0 then
      s
    else
      case s of
        Nil => Nil
      | Cons (_, tl) => drop (n - 1) (tl ())

  fun takeWhile p Nil = Nil
    | takeWhile p (Cons (x, tl)) =
        if p x then Cons (x, fn () => takeWhile p (tl ())) else Nil

  fun forAll p Nil = true
    | forAll p (Cons (x, tl)) =
        p x andalso forAll p (tl ())

  fun exists p Nil = false
    | exists p (Cons (x, tl)) =
        p x orelse exists p (tl ())

  fun map f Nil = Nil
    | map f (Cons (x, tl)) =
        Cons (f x, fn () => map f (tl ()))

  fun filter p Nil = Nil
    | filter p (Cons (x, tl)) =
        if p x then Cons (x, fn () => filter p (tl ())) else filter p (tl ())

  fun append Nil s2 = s2 ()
    | append (Cons (x, tl)) s2 =
        Cons (x, fn () => append (tl ()) s2)

  fun flatMap f Nil = Nil
    | flatMap f (Cons (x, tl)) =
        append (f x) (fn () => flatMap f (tl ()))

  fun constant a =
    Cons (a, fn () => constant a)

  fun from n =
    Cons (n, fn () => from (n + 1))

  fun fibs () =
    let
      fun go (a, b) =
        Cons (a, fn () => go (b, a + b))
    in
      go (0, 1)
    end

  fun unfold z f =
    case f z of
      NONE => Nil
    | SOME (a, z') => Cons (a, fn () => unfold z' f)
end
