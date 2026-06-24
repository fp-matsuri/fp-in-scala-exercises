# Standard ML 入門

この文書では，SML の文法・型・モジュールの仕組みを簡単にまとめています．

演習の進め方は [`README.md`](../README.md) を参照してください．コード片は REPL (`make repl`) に貼り付けて，その場で試せます．

## 目次

- [値・束縛・関数](#値束縛関数)
- [型](#型)
- [datatype とパターンマッチ](#datatype-とパターンマッチ)
- [再帰と末尾再帰](#再帰と末尾再帰)
- [例外](#例外)
- [ref と可変性](#ref-と可変性)
- [Value Restriction](#value-restriction)
- [モジュールシステム](#モジュールシステム)
- [等値型](#等値型)
- [よく使う標準ライブラリ](#よく使う標準ライブラリ)

## 値・束縛・関数

値は `val` で名前に束縛し，関数は `fun` で定義します．無名関数は `fn ... => ...` と書きます．

```sml
val x = 1 + 2                (* 3 : int *)
val name = "ml"              (* "ml" : string *)

fun square n = n * n         (* square : int -> int *)
val inc = fn n => n + 1      (* inc : int -> int *)
```

局所的な束縛は `let ... in ... end` の中に書きます．宣言だけを隠したいときは `local ... in ... end` を使い，`in` の前に置いた補助定義は外から見えません．

```sml
val y =
    let
      val a = 10
      val b = 20
    in
      a + b
    end
```

関数適用は `f x` のように書き，括弧は要りません．一方 `f (x, y)` は，引数を2つ渡しているのではなく，タプル `(x, y)` を1つ渡しています．引数の受け取り方にはタプルでまとめる方法と，カリー化して1つずつ受け取る方法の2通りがあり，カリー化した関数は引数を途中まで与えて新しい関数を作れます (部分適用)．

```sml
fun add (a, b) = a + b   (* add : int * int -> int *)
val r1 = add (3, 4)

fun add2 a b = a + b     (* add2 : int -> int -> int *)
val inc = add2 1         (* inc : int -> int *)
val r2 = inc 5
```

中置演算子は `op` を付ければ普通の関数として扱え，逆に自分の関数を中置にしたいときは `infix` (右結合なら `infixr`，数字は優先順位) で宣言します．

```sml
val add = op +
val r = add (3, 4)       (* 7 *)

infix 6 plus
fun a plus b = a + b
val n = 3 plus 4         (* 7 *)
```

論理積と論理和は `andalso`・`orelse` で書きます．どちらも左側だけで結果が決まれば右側を評価しない短絡演算です．

```sml
fun inRange n = n > 0 andalso n < 10
```

## 型

主な型は次のとおりです．

- 基本型: `int`，`real` (浮動小数)，`bool`，`char`，`string`，`unit` (値は `()` のみ)
- タプル: `int * string`，レコード: `{name: string, age: int}`
- リスト: `int list` (`[1, 2, 3]`，空は `[]`，先頭への追加は `::`，連結は `@`)
- 関数: `'a -> 'b`

`'a` は型変数で，任意の型を表します (多相)．たとえば `length : 'a list -> int` は，要素の型によらずどんなリストにも使えます．

```sml
val xs : int list = [1, 2, 3]
val ys = 0 :: xs              (* [0, 1, 2, 3]．:: は先頭に1要素を付ける *)
val zs = [1, 2] @ [3, 4]      (* [1, 2, 3, 4]．@ はリスト同士を連結する *)
val pair : int * bool = (1, true)
```

`type` で既存の型に別名を付けられます．たとえば `type point = int * int` と書くと，以降 `point` を `int * int` の代わりに使えます (中身は同じ型です)．

型注釈は `式 : 型` の形か，引数に `(n : int)` のように書きます．ふだんは型推論に任せ，必要なときにだけ書くのが普通です．

## datatype とパターンマッチ

代数的データ型 (直和型) は `datatype` で定義します．これは SML の中心となる仕組みです．

```sml
datatype color = Red | Green | Blue          (* 列挙 *)

datatype 'a tree =
    Leaf
  | Node of 'a tree * 'a * 'a tree            (* 再帰的なデータ型 *)
```

`option` (値があるか無いか) のように，よく使う型は標準ライブラリに定義済みです．

```sml
(* datatype 'a option = NONE | SOME of 'a *)
val x = SOME 42
val y = NONE
```

これらの値は，`case ... of` 式か，`fun` の複数の節でパターンマッチして分解します．

```sml
fun describe c =
    case c of
        Red => "あつい"
      | Green => "すすめ"
      | Blue => "さむい"

(* 関数を複数の節に分けてマッチする．再帰でリストを畳む例 *)
fun sum [] = 0
  | sum (x :: rest) = x + sum rest

(* as を使うと「全体」と「分解した中身」を同時に束縛できる *)
fun firstTwo (xs as (a :: b :: _)) = SOME (a, b, xs)
  | firstTwo _ = NONE
```

パターンが網羅されていないと，コンパイラが警告してくれます．`_` は何にでもマッチするワイルドカードです．

レコードもパターンマッチで中身を取り出せます．

```sml
val p = {name = "Alice", age = 20}

(* n = "Alice", a = 20 として束縛する *)
val {name = n, age = a} = p

(* 必要なフィールドだけ束縛する *)
fun greet {name, age} = "Hello " ^ name
val msg = greet p

(* #フィールド名 で直接アクセスもできる *)
val nm = #name p
```

## 再帰と末尾再帰

SML にはループ構文がないので，繰り返しは再帰で書きます．なかでも，呼び出しの結果をそのまま返す末尾再帰はスタックを消費しないため，累積引数 (アキュムレータ) を使って末尾再帰の形にするのが定石です．

```sml
(* 末尾再帰でない (呼び出しの後に + が残る) *)
fun lengthBad [] = 0
  | lengthBad (_ :: t) = 1 + lengthBad t

(* 末尾再帰 (acc に積んでいく) *)
fun length xs =
    let
      fun go (acc, []) = acc
        | go (acc, _ :: t) = go (acc + 1, t)
    in
      go (0, xs)
    end
```

互いに呼び合う関数は，`and` でつないで同時に定義します (相互再帰)．

```sml
fun isEven 0 = true
  | isEven n = isOdd (n - 1)
and isOdd 0 = false
  | isOdd n = isEven (n - 1)
```

## 例外

SML では，エラー処理に例外を普通に使います．

```sml
exception EmptyList
exception BadArg of string          (* 値を持たせることもできる *)

val e = EmptyList                   (* 例外も値 (exn 型) として扱える *)

fun head [] = raise EmptyList
  | head (x :: _) = x

val safe = head [] handle EmptyList => ~1   (* handle で捕捉する．~1 は -1 *)
```

## ref と可変性

可変なセルは `ref` で作れます．

```sml
val counter = ref 0                (* int ref *)
val () = counter := !counter + 1   (* := で代入し，! で中身を参照する *)
val now = !counter                 (* 1 *)
```

複数の式を順に評価したいときは，セミコロンで `(e1; e2; e3)` のように並べます．全体の値は最後の式の値になります．`ref` の更新や `print` のように，副作用を起こす処理を並べる場面で使います．

```sml
val () = (
  counter := !counter + 1;
  print "Updated!\n"
)
```

## Value Restriction

SML では，副作用と多相性の組み合わせで型安全性が崩れるのを防ぐため，束縛の右辺が構文上の値 (定数や `fn` など) でない場合には，型変数を多相型 (汎用的な `'a`) に一般化しません．

```sml
val r = ref []                  (* 型変数が一般化されず，未確定のまま *)
val r : int list ref = ref []   (* 注釈で型を固定すればよい *)
```

`ref` を使っていなくても，右辺が関数適用とみなされて一般化されないことがあります．多相性を保ちたいときは，`fn` で包んで構文上の値にします．

```sml
(* 一般化されず，型変数がダミー型に固定されてしまう *)
val id = List.rev o List.rev

(* 回避策: fn で明示的に引数を取る形にする *)
val id = fn xs => (List.rev o List.rev) xs
```

一般化できなかった束縛をエラーにするか警告で済ますかは処理系によります (この問題集で使う MLton と SML/NJ はどちらも警告に留め，ダミー型に固定して続行します)．

## モジュールシステム

モジュールシステムは SML の強みで，signature・structure・functor の3つの道具からなります．

### signature について

signature はモジュールの「型」にあたり，公開する型や値を並べたものです．

```sml
signature STACK =
sig
  type 'a t                       (* 抽象型．中身は見せない *)
  val empty : 'a t
  val push  : 'a -> 'a t -> 'a t
  val pop   : 'a t -> ('a * 'a t) option
end
```

### structure について

structure は signature に対応する実装です．

```sml
structure ListStack : STACK =
struct
  type 'a t = 'a list
  val empty = []
  fun push x s = x :: s
  fun pop [] = NONE
    | pop (x :: s) = SOME (x, s)
end
```

structure 内にはドットで `S.foo` のようにアクセスします．

`open S` と書いて展開することで，`S.foo` を `foo` のように修飾なしで使えるようになります．

```sml
structure M = struct val base = 10 fun double x = x * 2 end

structure UseM =
struct
  open M             (* 以降 base と double を M. なしで使える *)
  val n = double base
end
```

### 透過注釈 `:` と不透明注釈 `:>`

signature を当てる書き方には2通りあり，型の正体を隠すかどうかが違います．

- `structure S : SIG` … 透過 (transparent)．signature に書いた成分だけを公開しますが，`type 'a t = 'a list` のような型の正体は外からも見えます．
- `structure S :> SIG` … 不透明 (opaque)．signature で `type 'a t` とだけ宣言した型は抽象型になり，正体が隠れます．

```sml
structure ListStack : STACK = struct type 'a t = 'a list (* ... *) end
val xs : int ListStack.t = [1, 2, 3]  (* OK: list として扱える *)

structure S :> STACK = struct type 'a t = 'a list (* ... *) end
val ys : int S.t = [1, 2, 3]          (* エラー: S.t の正体が隠蔽されている *)
```

なお，`:>` で隠した型のうち一部だけを公開したいときは，signature に `where type T = ...` を付けて型等式を加えます (複数の型を持つ signature で，本体は隠しつつ補助的な型だけ見せたい場合に使います)．

### functor について
 
functor は，あるモジュールを受け取って別のモジュールを組み立てる「モジュールの関数」です．

```sml
signature ADD =
sig
  type t
  val zero : t
  val add : t * t -> t
end

functor MkPair (A : ADD) =
struct
  type t = A.t * A.t
  val zero = (A.zero, A.zero)
  fun add ((a1, b1), (a2, b2)) = (A.add (a1, a2), A.add (b1, b2))
end
```

引数には structure だけでなく，型そのものを取ることもできます．`(type s)` と書くと型 `s` を受け取る functor になり，適用時には `(type s = int)` のように型を渡します．

```sml
functor MkBox (type s) =
struct
  type t = s
  val items : s list ref = ref []
end

structure IntBox = MkBox (type s = int)
```

## 等値型

`=` で比較できる型を等値型と呼び，型変数では `''a` (アポストロフィ2つ) で表します．`int`・`string`・`bool`・タプル・リストなどは等値型ですが，`real` と関数は等値型ではありません．

```sml
(* real は等値型でないので 1.0 = 1.0 は型エラー．比較には Real.== を使う *)
val b1 = Real.== (1.0, 1.0)

fun member (_, []) = false
  | member (x, y :: ys) = x = y orelse member (x, ys)
(* member : ''a * ''a list -> bool *)
```

datatype が等値型になるのは，構成要素がすべて等値型のときだけです．関数を含むものは等値型になりません．

```sml
datatype color = Red | Green
val b2 = Red = Green               (* OK: 等値型 *)

datatype t = F of int -> int
(* F f = F g は型エラー: 関数を含むので等値型でない *)
```

signature で抽象型に等値比較を要求したいときは，`type` の代わりに `eqtype` と宣言します．

## よく使う標準ライブラリ

| 使い方 | 例 |
| --- | --- |
| `List.map` / `List.filter` / `List.foldl` / `List.foldr` | `List.foldl (op +) 0 [1, 2, 3]` |
| `List.rev` / `List.length` / `List.nth` / `List.tabulate` | `List.tabulate (3, fn i => i)` = `[0, 1, 2]` |
| `Option.map` / `Option.getOpt` / `Option.valOf` | `Option.getOpt (NONE, 0)` = `0` |
| `Int.toString` / `Int.compare` | `Int.toString 42` |
| 文字列: `^` (連結) / `String.size` / `concat` | `"a" ^ "b"`，`concat ["a", "b"]` |
| `f o g` (関数合成) | `(Math.sqrt o real) 9` = `3.0` |
| `print` | `print "hi\n"` |
