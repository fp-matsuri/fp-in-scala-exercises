(* 標準ライブラリの実装: {{:https://ocaml.org/manual/5.4/api/Either.html}[Stdlib.Either]}

   OCaml には {{:https://ocaml.org/manual/5.4/api/Result.html}[Stdlib.Result]} という、Either と同様の型も存在する。
   [Either]には left-biased なのか、right-biased なのか、という問題があり、これは言語や実装による。
   OCaml では [Either] をあくまで中道な型として定義し、正常値が欲しい場合には [Result] を使うことが推奨されている。

   一方で、Scala は right-biased であり、オリジナルに倣って、ここでは right-biased な [Either] を定義することにする。 *)

type (+'e, +'a) t = Left of 'e | Right of 'a

(** Exercise 4.6: [Option]に準じて [map], [flat_map], [or_else], [map2] を実装せよ。 *)

(* right-biased な実装。標準ライブラリには [map_left], [map_right] が存在し、[map] は存在しない。
   [map] を定義すると、どちらの場合に [f] を適用するのか決めなくてはならないためである。 
   以降の他の関数も同様。 *)
let map (f : 'a -> 'b) : ('err, 'a) t -> ('err, 'b) t = function
  | Left e -> Left e
  | Right a -> Right (f a)

let flat_map (f : 'a -> ('err, 'b) t) : ('err, 'a) t -> ('err, 'b) t = function
  | Left e -> Left e
  | Right a -> f a

let or_else (other : ('err, 'a) t) : ('err, 'a) t -> ('err, 'a) t = function
  | Left _ -> other
  | Right a -> Right a

let map2 (f : 'a -> 'b -> 'c) (ea : ('err, 'a) t) (eb : ('err, 'b) t) :
    ('err, 'c) t =
  match (ea, eb) with
  | Left e, _ -> Left e
  | _, Left e -> Left e
  | Right a, Right b -> Right (f a b)

(** OCaml には Haskell の do notation や Scala の for-comprehension に相当する構文はない。
    しかし、OCamlでは、変数束縛の演算子をユーザーが定義する機能が存在する。
    いわゆるモナドのためのこの記法は、実は、変数束縛こそが重要であると観察できるだろう。

    OCaml では、以下のようにして do notation や for-comprehension と同様の記法を実現できる。

    @see <https://ocaml.org/manual/5.4/bindingops.html> binding operators *)
let ( let* ) x f = flat_map f x

let map2_monadic f ea eb =
  let* a = ea in
  let* b = eb in
  Right (f a b)

(* binding operators では let-punning と呼ばれる省略記法もある。
   通常の利用では恩恵が少ないかもしれないが、場合によっては有効だ。 *)
let map2_monadic_punning f a b =
  (* let* a = a in *)
  let* a in
  (* let* b = b in *)
  let* b in
  Right (f a b)

(** Exercise 4.7: [Option]に準じて [traverse], [sequence] を実装せよ。 *)

let rec traverse (f : 'a -> ('err, 'b) t) : 'a list -> ('err, 'b list) t =
  function
  | [] -> Right []
  | x :: xs -> map2 List.cons (f x) @@ traverse f xs

let traverse_1 f xs =
  List.fold_right (fun x acc -> map2 List.cons (f x) acc) xs (Right [])

let sequence (es : ('err, 'a) t list) : ('err, 'a list) t = traverse Fun.id es

let mean = function
  | [] -> Left "mean of empty array!"
  | xs ->
      let n = float (List.length xs) in
      Right (List.fold_left ( +. ) 0.0 xs /. n)

let safe_div x y = try Right (x / y) with e -> Left e

(** thunk を引数に使い、任意の関数の例外を Either に変換する。 *)
let catch f = try Right (f ()) with e -> Left e

(* エラーのリストを Left に蓄積する実装 *)

let map2_all (f : 'a -> 'b -> 'c) (ea : ('err list, 'a) t)
    (eb : ('err list, 'b) t) : ('err list, 'c) t =
  let get_errors = function Right _ -> [] | Left es -> es in
  match (ea, eb) with
  | Right a, Right b -> Right (f a b)
  | ea, eb -> Left (get_errors ea @ get_errors eb)

let rec traverse_all (f : 'a -> ('err list, 'b) t) :
    'a list -> ('err list, 'b list) t = function
  | [] -> Right []
  | x :: xs -> map2_all List.cons (f x) @@ traverse_all f xs

let sequence_all (es : ('err list, 'a) t list) : ('err list, 'a list) t =
  traverse_all Fun.id es

(* 今後のためのエイリアス *)
type ('e, 'a) either = ('e, 'a) t

module Name : sig
  (* 単に [type t = Name of string] とすると、実体を隠蔽出来ない。
     signature で抽象型にしておくことでモジュール外からは実体 (string) が分からないようになる。 *)
  type t

  val make : string -> (string, t) either
  val get : t -> string
end = struct
  type t = string

  let make = function "" -> Left "Name is empty." | name -> Right name

  (* 実装はただの恒等関数になるが、モジュール外から実体が見えないのが重要 *)
  let get = Fun.id
end

module Age : sig
  type t

  val make : int -> (string, t) either
  val get : t -> int
end = struct
  type t = int

  let make age = if age < 0 then Left "Age is out of range." else Right age
  let get = Fun.id
end

(* シグネチャを書かない場合、全て公開される。
   レコード型のシグネチャがないと一々アクセサを書く必要があり、面倒なので、ここでは公開している。
 *)
module Person = struct
  type t = { name : Name.t; age : Age.t }

  let make (~name, ~age) =
    (* record や labeld-tuple では [name = name] のような記述を単に [name] に省略できる。
       つまり、[{ name; age }] は [{ name = name; age = age }] と同等。
     *)
    map2 (fun name age -> { name; age }) (Name.make name) (Age.make age)
end

let map2_both a b f =
  match (a, b) with
  | Right a, Right b -> Right (f a b)
  | Left e, Right _ -> Left [ e ]
  | Right _, Left e -> Left [ e ]
  | Left a, Left b -> Left [ a; b ]

let make_both name age =
  map2_both (Name.make name) (Age.make age) @@ fun name age ->
  (* レコード型の型推論の際には対象の型がモジュールに閉じていると見つけられない。
     よって、型を明示するか、モジュールを明示する必要がある。 *)
  Person.{ name; age }
