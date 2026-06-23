(* 第9章 解答例 (Parser)．入力は文字列 + 位置で持ち回す． *)
structure Parser :> PARSER =
struct
  datatype 'a presult = Ok of 'a * int | Err of string
  type 'a parser = string -> int -> 'a presult
  datatype 'a result = Success of 'a | Failure of string

  fun run p s =
    case p s 0 of
      Ok (a, _) => Success a
    | Err msg => Failure msg

  fun succeed a =
    fn s => fn i => Ok (a, i)

  fun fail msg =
    fn s => fn i => Err msg

  fun satisfy pred =
    fn s =>
      fn i =>
        if i < size s andalso pred (String.sub (s, i)) then
          Ok (String.sub (s, i), i + 1)
        else
          Err ("位置 " ^ Int.toString i ^ ": 想定外の文字")

  fun char c =
    satisfy (fn x => x = c)

  fun string lit =
    fn s =>
      fn i =>
        let
          val n = size lit
        in
          if i + n <= size s andalso String.substring (s, i, n) = lit then
            Ok (lit, i + n)
          else
            Err ("位置 " ^ Int.toString i ^ ": \"" ^ lit ^ "\" を期待")
        end

  fun map f p =
    fn s =>
      fn i =>
        (case p s i of
           Ok (a, i') => Ok (f a, i')
         | Err m => Err m)

  fun flatMap f p =
    fn s =>
      fn i =>
        (case p s i of
           Ok (a, i') => f a s i'
         | Err m => Err m)

  fun map2 f pa pb =
    flatMap (fn a => map (fn b => f (a, b)) pb) pa

  fun product (pa, pb) =
    map2 (fn x => x) pa pb

  fun or (p1, p2) =
    fn s =>
      fn i =>
        (case p1 s i of
           Ok r => Ok r
         | Err _ => p2 s i)

  fun many p =
    fn s =>
      fn i =>
        let
          fun loop (acc, j) =
            case p s j of
              Ok (a, j') =>
                if j' = j then (List.rev acc, j) (* 無限ループ防止 *)
                else loop (a :: acc, j')
            | Err _ => (List.rev acc, j)
          val (xs, j) = loop ([], i)
        in
          Ok (xs, j)
        end

  fun many1 p =
    map2 (fn (x, xs) => x :: xs) p (many p)

  fun listOfN n p =
    if n <= 0 then succeed []
    else map2 (fn (x, xs) => x :: xs) p (listOfN (n - 1) p)

  fun sepBy p sep =
    let
      val rest = many (flatMap (fn _ => p) sep)
      val nonEmpty = map2 (fn (x, xs) => x :: xs) p rest
    in
      or (nonEmpty, succeed [])
    end

  fun lazy thunk =
    fn s => fn i => thunk () s i
end
