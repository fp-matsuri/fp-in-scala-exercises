(* A comment! *)

(** A documentation comment
    @see <https://ocaml.org/manual/5.4/doccomments.html> doccomments manual
    @see <https://ocaml.org/manual/5.4/ocamldoc.html> ocamldoc manual *)
module My_program : sig
  val abs : int -> int
  val print_abs : unit -> unit
  val factorial : int -> int
  val fib : int -> int
  val format_result : string -> int -> (int -> int) -> string
end = struct
  let abs n = if n < 0 then -n else n

  (** モジュールのシグネチャに現れない値は公開されないため、モジュール外から参照されない *)
  let format_abs x = Printf.sprintf "The absolute value of %d is %d" x (abs x)

  let print_abs () = print_endline (format_abs (-42))

  (** ローカルな再帰関数を定義して実装 *)
  let factorial n =
    let rec go n acc = if n <= 0 then acc else go (n - 1) (n * acc) in
    go n 1

  (** [while]を利用した[factorial]の別実装。signature に現れないため、外部から参照されない。
      モジュール内で利用されないため、unused の警告が出ないように名前をアンダースコアで始める。 *)
  let _factorial2 n =
    (* refによる参照型を利用することで可変な変数を定義できる *)
    let acc = ref 1 in
    let i = ref n in
    while !i > 0 do
      acc := !acc * !i;
      i := !i - 1
    done;
    !acc

  (** Exercise 2.1: n番目のフィボナッチ数を計算する関数[fib]を定義せよ。 *)
  let rec fib = function
    | 0 -> 0
    | 1 -> 1
    (* パターンマッチ時にガードを付けられる。キーワードが[if]じゃなくて[when]なことに注意。 *)
    | n when n > 1 -> fib (n - 1) + fib (n - 2)
    | _ -> failwith "Negative input is not allowed"

  (** [formatAbs]とよく似た定義。これも利用されないサンプル実装。 *)
  let _format_factorial n =
    Printf.sprintf "The factorial of %d is %d." n (factorial n)

  (** [format_abs],[_format_factorial]を一般化して、必要なパラメータを受け取るようにする *)
  let format_result name n f = Printf.sprintf "The %s of %d is %d." name n (f n)
end

module Format_abs_and_factorial = struct
  (* [open]は他の言語でいう[import]に相当する。 *)
  open My_program

  let printAbsAndFactorial () =
    print_endline (format_result "absolute value" (-42) abs);
    print_endline (format_result "factorial" 7 factorial)
end

module Test_fib = struct
  open My_program

  let print_fib () =
    Printf.printf "Expected: 0, 1, 1, 2, 3, 5, 8\n";
    Printf.printf "Actual:   %d, %d, %d, %d, %d, %d, %d\n" (fib 0) (fib 1)
      (fib 2) (fib 3) (fib 4) (fib 5) (fib 6)
end

(** 関数型プログラミング(FP)では関数を取り回すことがよくあるため、名前を付けること{b なく}関数を組み立てるシンタックスがあると便利だ *)
module Anonymous_functions = struct
  open My_program

  let print_anonymous_functions () =
    print_endline (format_result "absolute value" (-42) abs);
    print_endline (format_result "factorial" 7 factorial);
    print_endline (format_result "increment" 7 (fun (x : int) -> x + 1));
    print_endline (format_result "increment2" 7 (fun x -> x + 1));
    print_endline (format_result "increment3" 7 (( + ) 1));
    print_endline (format_result "increment4" 7 succ);
    print_endline
      (format_result "increment5" 7 (fun x ->
           let r = x + 1 in
           r))
end

module Monomorphic_binary_search = struct
  (** まずは[string]に特化した[find_first]。理想的には任意の[array]に対して動作するように一般化できるだろう。 *)
  let find_first ss key =
    let rec loop n =
      (* [n]が配列の終わりを過ぎたら、キーが配列に存在しないことを示す[-1]を返す *)
      if n >= Array.length ss then -1
      else if
        (* [ss.(n)]は配列[ss]の[n]番目の要素を抽出する。 *)
        ss.(n) = key
      then
        (* [n]番目の要素がキーと等しい場合、[n]を返す。
           これは、要素がそのインデックスで配列に現れることを示す。 *)
        n
      else
        (* そうでなければ、[n]をインクリメントして探し続ける *)
        loop (n + 1)
    in
    (* ループは配列の最初の要素から開始する *)
    loop 0
end

module Polymorphic_functions = struct
  (** こちらは多相(ポリモーフィック)版の[find_first]であり、['a]型の値が探している要素かどうかをテストする関数でパラメータ化されている。
      [string]をハードコードせず、任意の型['a]に対して動作するように一般化されている。
      そして、与えられたキーに対する等価判定をハードコードする代わりに配列の個々の要素をテストする関数をとる。
      @see <https://ocaml.org/manual/5.4/types.html> ['a]は多相型を表す構文です。 *)
  let find_first (a : 'a array) (p : 'a -> bool) =
    let rec loop n =
      if n >= Array.length a then -1
      else if
        (* 関数[p]が現在の要素にマッチしたら、合うものが見つかったということで配列のそのインデックスを返す。 *)
        p a.(n)
      then n
      else loop (n + 1)
    in
    loop 0

  (** Exercise 2.2: 配列がソート済みかどうかを判定する多相関数を定義せよ。
      @param array ソート済みか判定する対象の配列
      @param gt 配列[array]の隣接する2要素をとって最初の要素が2番目の要素より大きいかどうかを判定する述語関数。 *)
  let sorted a gt =
    let rec loop n =
      if n >= Array.length a - 1 then true
      else if gt a.(n) a.(n + 1) then false
      else loop (n + 1)
    in
    loop 0

  (** 多相関数はたいてい型によって制約されているため、対応する実装がひとつしかないことがある。[partial1]はその一例。
      OCamlの型推論は優秀なので、この程度なら明示せずとも正しく推論されるが、今回は教育のために明示している。 *)
  let partial1 (a : 'a) (f : 'a -> 'b -> 'c) : 'b -> 'c = fun b -> f a b

  (** Exercise 2.3: [curry] を実装せよ。*)
  let curry (f : 'a * 'b -> 'c) : 'a -> 'b -> 'c = fun a b -> f (a, b)

  (** Exercise 2.4: [uncurry] を実装せよ。*)
  let uncurry (f : 'a -> 'b -> 'c) : 'a * 'b -> 'c = fun (a, b) -> f a b

  (** Exercise 2.5: [compose] を実装せよ。*)
  let compose (f : 'b -> 'c) (g : 'a -> 'b) : 'a -> 'c = fun a -> f (g a)
end
