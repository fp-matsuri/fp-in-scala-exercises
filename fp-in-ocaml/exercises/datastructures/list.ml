(* 標準ライブラリの実装: {{:https://ocaml.org/manual/5.4/api/List.html}[Stdlib.List]} *)

(* OCaml ではファイル名とモジュール名が対応している。
   例えば、今回の[list.ml]はモジュール[List]を定義するファイルになる。
   このモジュールを実装することで、標準ライブラリの方のリストは覆い隠される(shadowing)ことに注意。 *)

(** 慣例的にモジュールの型は[t]で定義することが多い。
    また、OCamlでは、変数定義([let])はデフォルト非再帰だが、データ型定義([type])はデフォルト再帰になる。

    [+]は変位指定で共変を意味する。一方で、今回の例では具体型が公開されており、構造から変位が定まるため、本来不要。
    具体型に対する変位指定は、具体型との整合性の検査のために利用される。
    @see <https://ocaml.org/manual/5.4/typedecl.html> 変位(variance)について記載 *)
type +'a t =
  (* 空リストを表す。 *)
  | Nil
  (* 非空リストを表す。['a t]は[Nil]か、また別の[Cons]の可能性がある。 *)
  | Cons of 'a * 'a t

(*
  標準ライブラリでは[List.t]は以下のように定義されている。

  type 'a t = 'a list = 
  | []
  | (::) of 'a * 'a list

  この実装なら[Cons]が演算子になっているため、[1 :: 2 :: 3 :: []]のようにリストを構築できる。
  自前で実装する際にもこの定義は利用可能だが、今回はあえて fp-in-scala と合わせている。
 *)

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
let rec make = function
  (* function は fun x -> match x with と同じで、引数に対するパターンマッチを記述できる *)
  | [] -> Nil
  | x :: xs -> Cons (x, make xs)

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
let tail : 'a t -> 'a t = function _ -> failwith "Not implemented"

(** Exercise 3.3: リストの先頭要素を別の値に置き換える関数[set_head]を定義せよ。 *)
let set_head (_h : 'a) : 'a t -> 'a t = function
  | _ -> failwith "Not implemented"

(** Exercise 3.4: リストの先頭から[n]個の要素を取り除く関数[drop]を定義せよ。 *)
let rec drop (_n : int) : 'a t -> 'a t = function
  | _ -> failwith "Not implemented"

(** Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数[drop_while]を定義せよ。 *)
let rec drop_while (_f : 'a -> bool) : 'a t -> 'a t = function
  | _ -> failwith "Not implemented"

(** Exercise 3.6: 末尾要素以外のリストを返す関数[init]を定義せよ。 *)
let rec init : 'a t -> 'a t = function _ -> failwith "Not implemented"

(** Exercise 3.7: [fold_right]によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか? *)

(** Exercise 3.8: [fold_right]の引数[acc]に[Nil]、[f]に[Cons(_, _)]を与えるとどのような結果が得られるか?
    (推測してからREPLで確認してみよう) *)

(** Exercise 3.9: リストの要素数を数える関数[length]を定義せよ。 *)
let length (_l : 'a t) : int = failwith "Not implemented"

(** Exercise 3.10: リストを左端から畳み込む[fold_left]関数を末尾再帰関数として定義せよ。 *)
let rec fold_left (_acc : 'b) (_f : 'b -> 'a -> 'b) : 'a t -> 'b = function
  | _ -> failwith "Not implemented"

(** Exercise 3.11: [fold_left]を用いて[sum],[product],[length]を定義せよ。 *)
let sum_via_fold_left (_ns : int t) : int = failwith "Not implemented"

let product_via_fold_left (_ns : float t) : float = failwith "Not implemented"
let length_via_fold_left (_l : 'a t) : int = failwith "Not implemented"

(** Exercise 3.12: [fold_left]を用いてリストを逆順にする関数[reverse]を定義せよ。 *)
let reverse (_l : 'a t) : 'a t = failwith "Not implemented"

(** Exercise 3.13: [fold_left]を用いて[fold_right]を定義することは可能か? 可能であれば定義せよ。 *)

(** Exercise 3.14: [fold_right]を用いて[append]を定義せよ。 *)
let append_via_fold_right (_l : 'a t) (_r : 'a t) : 'a t =
  failwith "Not implemented"

(** Exercise 3.15: [fold_right]を用いてリストのリストを1つのリストに連結する関数[concat]を定義せよ。 *)
let concat (_l : 'a t t) : 'a t = failwith "Not implemented"

(** Exercise 3.16: [fold_right]を用いてリストの各要素に1を加える関数[increment_each]を定義せよ。 *)
let increment_each (_l : int t) : int t = failwith "Not implemented"

(** Exercise 3.17: [fold_right]を用いてリストの各要素の数値を文字列に変換する関数[double_to_string]を定義せよ。
*)
let double_to_string (_l : float t) : string t = failwith "Not implemented"

(** Exercise 3.18: [double_to_string]を一般化して、リストの各要素に関数[f]を適用する関数[map]を定義せよ。 *)
let map (_l : 'a t) (_f : 'a -> 'b) : 'b t = failwith "Not implemented"

(** Exercise 3.19: リストの各要素を述語関数[f]に従ってフィルタリングする関数[filter]を定義せよ。 *)
let filter (_l : 'a t) (_f : 'a -> bool) : 'a t = failwith "Not implemented"

(** Exercise 3.20: リストの各要素を関数[f]に適用して得られるリストのリストを1つのリストに連結する関数[flat_map]を定義せよ。
*)
let flat_map (_l : 'a t) (_f : 'a -> 'b t) : 'b t = failwith "Not implemented"

(** Exercise 3.21: [flat_map]を用いて[filter]を定義せよ。 *)
let filter_via_flat_map (_l : 'a t) (_f : 'a -> bool) : 'a t =
  failwith "Not implemented"

(** Exercise 3.22: リスト[a], [b]をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを
    返す関数[add_pairwise]を定義せよ。[a], [b]の長さが異なる場合、返すリストの長さは短いほうに一致する。 *)
let add_pairwise (_a : int t) (_b : int t) : int t = failwith "Not implemented"

(** Exercise 3.23: [add_pairwise]を一般化して、リスト[a], [b]をそれぞれ先頭から順に取り出して
    対応する要素に関数[f]を適用して得られたリストを返す関数[zip_with]をシグネチャ含め定義せよ。 *)
let zip_with _ _ _ = failwith "Not implemented"

(** Exercise 3.24:
    リスト[sup]の中にリスト[sub]が部分列として含まれているかどうかを判定する関数[has_subsequence]を定義せよ。

    例: [make [1;2;3;4]] は [make [1;2]], [make [2;3]], [make [4]] を部分列として含むが、
    [make [1;4]] は部分列として含まない。 *)
let has_subsequence (_sup : 'a t) (_sub : 'a t) : bool =
  failwith "Not implemented"
