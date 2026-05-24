(** 慣例的にモジュールの型は[t]で定義することが多い。
    また、OCamlでは、変数定義([let])はデフォルト非再帰だが、データ型定義([type])はデフォルト再帰になる。

    [+]は変位指定で共変を意味する。一方で、今回の例では具体型が公開されており、構造から変位が定まるため、本来不要。
    具体型に対する変位指定は、具体型との整合性の検査のために利用される。
    @see <https://ocaml.org/manual/5.4/typedecl.html> 変位(variance)について記載 *)
type +'a t =
  | Nil (* 空リストを表す。 *)
  | Cons of 'a * 'a t (* 非空リストを表す。['a t]は[Nil]か、また別の[Cons]の可能性がある。 *)

(** パターンマッチングを用いて整数のリストの合計を計算する関数 *)
let rec sum (ints : int t) : int =
  match ints with
  | Nil -> 0 (* 空リストの合計は0 *)
  | Cons (x, xs) -> x + sum xs (* 先頭がxのリストの合計は、xと残りのリストの合計の和 *)

let rec product (floats : float t) : float =
  (* OCamlの浮動小数点数はデフォルトで倍精度 *)
  match floats with
  | Nil -> 1.0
  | Cons (0.0, _) -> 0.0
  | Cons (x, xs) ->
      x *. product xs (* OCamlの四則演算の演算子は単相のため、[float]に対しては[*.]を使用する必要がある *)

(* OCaml には variadic function がない。代わりに標準ライブラリのリストから変換する関数を作っておく *)
let rec make = function [] -> Nil | x :: xs -> Cons (x, make xs)

(** Exercise 3.1: 以下の式 `result `の評価結果は何になるか? (推測してからREPLで確認してみよう) *)
let[@warning "-11"] result =
  match make [ 1; 2; 3; 4; 5 ] with
  | Cons (x, Cons (2, Cons (4, _))) -> x
  | Nil -> 42
  | Cons (x, Cons (y, Cons (3, Cons (4, _)))) -> x + y
  | Cons (h, t) -> h + sum t
  | _ -> 101

let rec append (a1 : 'a t) (a2 : 'a t) : 'a t =
  match a1 with Nil -> a2 | Cons (h, t) -> Cons (h, append t a2)

let rec fold_right (a : 'a t) (acc : 'b) (f : 'a -> 'b -> 'b) : 'b =
  match a with Nil -> acc | Cons (x, xs) -> f x (fold_right xs acc f)

let sum_via_fold_right (ns : int t) : int = fold_right ns 0 (fun x y -> x + y)
let product_via_fold_right (ns : float t) : float = fold_right ns 1.0 ( *. )

(** Exercise 3.2: 先頭要素以外のリストを返す関数[tail]を定義せよ。 *)
let tail : 'a t -> 'a t = function
  | Nil -> failwith "tail of empty list"
  | Cons (_, t) -> t

(** Exercise 3.3: リストの先頭要素を別の値に置き換える関数[set_head]を定義せよ。 *)
let set_head (h : 'a) : 'a t -> 'a t = function
  | Nil -> failwith "set_head of empty list"
  | Cons (_, t) -> Cons (h, t)

(** Exercise 3.4: リストの先頭から[n]個の要素を取り除く関数[drop]を定義せよ。 *)
let rec drop (n : int) : 'a t -> 'a t = function
  | Cons (_, t) when 0 < n -> drop (n - 1) t
  | l -> l

(** Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数[drop_while]を定義せよ。 *)
let rec drop_while (f : 'a -> bool) : 'a t -> 'a t = function
  | Cons (h, t) when f h -> drop_while f t
  | l -> l

(** Exercise 3.6: 末尾要素以外のリストを返す関数[init]を定義せよ。 *)
let rec init : 'a t -> 'a t = function
  | Nil -> failwith "init of empty list"
  | Cons (_, Nil) -> Nil
  | Cons (h, t) -> Cons (h, init t)

(** 末尾再帰にしたバージョン。デフォルト引数を隠したければクロージャにしても良い。
    [[@tailcall]]によって、それが末尾呼び出しであることを検査できる。 *)
let rec init_tailrec ?(acc = Nil) = function
  | Nil -> failwith "init of empty list"
  | Cons (_, Nil) -> acc
  | Cons (h, t) -> (init_tailrec [@tailcall]) ~acc:(Cons (h, acc)) t

(** また、実は[init]のようなパターンも末尾再帰へ自動的な変換が可能であると知られている。

    このパターンは{b Tail Modulo Constructor}と呼ばれている。ユーザー定義の場合も含めて、末尾でデータ構築子を呼び出しており、かつ、その引数で末尾呼び出しになっていれば、末尾再帰に変換できる。

    以下のように[[@tail_mod_cons]]属性を付与することで、最適化を有効にでき、[init_tailrec]のように扱える。 *)
let[@tail_mod_cons] rec init_tmc = function
  | Nil -> failwith "init of empty list"
  | Cons (_, Nil) -> Nil
  | Cons (h, t) -> Cons (h, init_tmc t)

(** Exercise 3.7: [fold_right]によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか? *)

(* [fold_right]はリストの末尾から先頭に向かって走査するため、途中で打ち切ることはできない。
   これは、[fold_right]が再帰的にリストの末尾まで到達してから結果を組み立てるためである。
   もし途中で打ち切る必要がある場合は、[fold_left]を使用するか、別のアプローチ (Chapter5) を検討する必要がある。 *)

(** Exercise 3.8: [fold_right]の引数[acc]に[Nil]、[f]に[Cons(_, _)]を与えるとどのような結果が得られるか?
    (推測してからREPLで確認してみよう) *)

(* 元のリストがそのまま得られる。
    例えば、リスト [1; 2; 3] に対して [fold_right] を適用すると、以下のように評価される:
    fold_right (Cons (1, Cons (2, Cons (3, Nil))) Nil (fun x acc -> Cons (x, acc))
    => Cons (1, fold_right (Cons (2, Cons (3, Nil)) Nil (fun x acc -> Cons (x, acc)))
    => Cons (1, Cons (2, fold_right (Cons (3, Nil)) Nil (fun x acc -> Cons (x, acc)))
    => Cons (1, Cons (2, Cons (3, fold_right Nil Nil (fun x acc -> Cons (x, acc))))
    => Cons (1, Cons (2, Cons (3, Nil)))
  *)

(** Exercise 3.9: リストの要素数を数える関数[length]を定義せよ。 *)
let length (l : 'a t) : int = fold_right l 0 (fun _ acc -> acc + 1)

(** Exercise 3.10: リストを左端から畳み込む[fold_left]関数を末尾再帰関数として定義せよ。 *)
let rec fold_left (acc : 'b) (f : 'b -> 'a -> 'b) : 'a t -> 'b = function
  | Nil -> acc
  | Cons (x, xs) -> fold_left (f acc x) f xs

(** Exercise 3.11: [fold_left]を用いて[sum],[product],[length]を定義せよ。 *)

let sum_via_fold_left (ns : int t) : int = fold_left 0 ( + ) ns
let product_via_fold_left (ns : float t) : float = fold_left 1.0 ( *. ) ns
let length_via_fold_left (l : 'a t) : int = fold_left 0 (fun acc _ -> acc + 1) l

(** [sum_via_fold_left]や[product_via_fold_left]は部分適用を利用して、単純に定義することもできる。
    やりすぎると分かりにくくなる場合もあるので注意。 *)

let sum_via_fold_left2 = fold_left 0 ( + )
let product_via_fold_left2 = fold_left 1.0 ( *. )

(* 一方で、length_via_fold_left は省略できない。
   OCamlの value restriction により、部分適用された関数が多相的な型を持つ場合、その型変数は一般化されないため、エラーとなる。

$ dune build
File "answers/datastructures/list.ml", line 115, characters 4-25:
115 | let length_via_fold_left2 = fold_left 0 (fun acc _ -> acc + 1)
          ^^^^^^^^^^^^^^^^^^^^^
Error: The type of this expression, '_weak1 t -> int,
       contains the non-generalizable type variable(s): '_weak1.
       (see manual section 6.1.2)

    @see <https://ocaml.org/manual/5.4/polymorphism.html#ss:valuerestriction> 6.1.2 The value restriction
 *)

(** Exercise 3.12: [fold_left]を用いてリストを逆順にする関数[reverse]を定義せよ。 *)
let reverse (l : 'a t) : 'a t = fold_left Nil (fun acc x -> Cons (x, acc)) l

(** Exercise 3.13: [fold_left]を用いて[fold_right]を定義することは可能か? 可能であれば定義せよ。 *)

(** [fold_right]を[reverse]と[fold_left]を使って実装することは、スタックオーバーフローを回避するための一般的な手法です。
    この章で実装したような厳密な[fold_right]関数を実装する場合に有効です。（これについては、後の章（laziness）で改めて取り上げます。）

    これらの実装は理論的な興味の対象であり、スタックセーフではなく、大きなリストには対応していません。

    なお、以下の実装は、スタックセーフではなく、大きなリストには対応していません。 *)

let fold_right_via_fold_left (a : 'a t) (acc : 'b) (f : 'a -> 'b -> 'b) : 'b =
  fold_left acc (fun acc x -> f x acc) (reverse a)

(** 以下の実装では、関数の連鎖を構築し、それが呼び出されると、正しい結合規則に従って操作が実行されます。
    ここでは、['b]型を['b -> 'b]として[foldRight]を呼び出し、`acc` 引数で呼び出しています。
    もし分かりにくい場合は、[fold_left_via_fold_right 0 (+) (make [1; 2; 3])]のような簡単な例を使って、定義を展開してみてください。

    なお、[|>]はパイプライン演算子と呼ばれ、左辺の値を右辺の関数として渡します。F# から OCaml に逆輸入されました。
    パイプライン演算子の発祥は定理証明支援系の Isabelle/ML とされています。 *)

let fold_right_via_fold_left2 (a : 'a t) (acc : 'b) (f : 'a -> 'b -> 'b) : 'b =
  acc |> fold_left (fun b -> b) (fun g a -> fun b -> g (f a b)) a

let fold_left_via_fold_right (acc : 'b) (f : 'b -> 'a -> 'b) (a : 'a t) : 'b =
  acc |> fold_right a (fun b -> b) (fun a g -> fun b -> g (f b a))

(** Exercise 3.14: [fold_right]を用いて[append]を定義せよ。 *)
let append_via_fold_right (l : 'a t) (r : 'a t) : 'a t =
  fold_right l r (fun x acc -> Cons (x, acc))

(** Exercise 3.15: [fold_right]を用いてリストのリストを1つのリストに連結する関数[concat]を定義せよ。 *)
let concat (l : 'a t t) : 'a t = fold_right l Nil append

(** Exercise 3.16: [fold_right]を用いてリストの各要素に1を加える関数[increment_each]を定義せよ。 *)
let increment_each (l : int t) : int t =
  fold_right l Nil (fun x acc -> Cons (x + 1, acc))

(** Exercise 3.17: [fold_right]を用いてリストの各要素の数値を文字列に変換する関数[double_to_string]を定義せよ。
*)
let double_to_string (l : float t) : string t =
  fold_right l Nil (fun x acc -> Cons (string_of_float x, acc))

(** Exercise 3.18: [double_to_string]を一般化して、リストの各要素に関数[f]を適用する関数[map]を定義せよ。 *)
let map (l : 'a t) (f : 'a -> 'b) : 'b t =
  fold_right l Nil (fun x acc -> Cons (f x, acc))

(** Exercise 3.19: リストの各要素を述語関数[f]に従ってフィルタリングする関数[filter]を定義せよ。 *)
let filter (l : 'a t) (f : 'a -> bool) : 'a t =
  fold_right l Nil (fun x acc -> if f x then Cons (x, acc) else acc)

(** Exercise 3.20: リストの各要素を関数[f]に適用して得られるリストのリストを1つのリストに連結する関数[flat_map]を定義せよ。
*)
let flat_map (l : 'a t) (f : 'a -> 'b t) : 'b t = concat (map l f)

(** Exercise 3.21: [flat_map]を用いて[filter]を定義せよ。 *)
let filter_via_flat_map (l : 'a t) (f : 'a -> bool) : 'a t =
  flat_map l (fun x -> if f x then Cons (x, Nil) else Nil)

(** Exercise 3.22: リスト[a], [b]をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを
    返す関数[add_pairwise]を定義せよ。[a], [b]の長さが異なる場合、返すリストの長さは短いほうに一致する。 *)
let rec add_pairwise (a : int t) (b : int t) : int t =
  match (a, b) with
  | Nil, _ | _, Nil -> Nil
  | Cons (x, xs), Cons (y, ys) -> Cons (x + y, add_pairwise xs ys)

(** Exercise 3.23: [add_pairwise]を一般化して、リスト[a], [b]をそれぞれ先頭から順に取り出して
    対応する要素に関数[f]を適用して得られたリストを返す関数[zip_with]をシグネチャ含め定義せよ。 *)
let rec zip_with (a : 'a t) (b : 'b t) (f : 'a -> 'b -> 'c) : 'c t =
  match (a, b) with
  | Nil, _ | _, Nil -> Nil
  | Cons (x, xs), Cons (y, ys) -> Cons (f x y, zip_with xs ys f)

(** Exercise 3.24:
    リスト[sup]の中にリスト[sub]が部分列として含まれているかどうかを判定する関数[has_subsequence]を定義せよ。

    例: [make [1;2;3;4]] は [make [1;2]], [make [2;3]], [make [4]] を部分列として含むが、
    [make [1;4]] は部分列として含まない。 *)
let has_subsequence (sup : 'a t) (sub : 'a t) : bool =
  let rec starts_with l prefix =
    match (l, prefix) with
    | _, Nil -> true
    | Cons (h1, t1), Cons (h2, t2) when h1 = h2 ->
        (starts_with [@tailcall]) t1 t2
    | _ -> false
  in
  let rec go = function
    | Nil -> sub = Nil
    | l when starts_with l sub -> true
    | Cons (_, t) -> (go [@tailcall]) t
  in
  go sup
