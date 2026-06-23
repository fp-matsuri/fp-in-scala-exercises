(* 第2章 解答例． *)
structure Intro: INTRO =
struct
  fun fib n =
    let
      fun go (0, prev, _) = prev
        | go (k, prev, cur) =
            go (k - 1, cur, prev + cur)
    in
      go (n, 0, 1)
    end

  fun isSorted (xs, ordered) =
    case xs of
      a :: (rest as b :: _) => ordered (a, b) andalso isSorted (rest, ordered)
    | _ => true

  fun curry f a b = f (a, b)

  fun uncurry f (a, b) = f a b

  fun compose f g = f o g
end
