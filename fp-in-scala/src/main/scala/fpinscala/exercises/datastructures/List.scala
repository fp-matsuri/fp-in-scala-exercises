package fpinscala.exercises.datastructures

/** `List` data type, parameterized on a type, `A`. */
enum List[+A]:
  /** A `List` data constructor representing the empty list. */
  case Nil

  /** Another data constructor, representing nonempty lists. Note that `tail` is
    * another `List[A]`, which may be `Nil` or another `Cons`.
    */
  case Cons(head: A, tail: List[A])

object List: // `List` companion object. Contains functions for creating and working with lists.
  def sum(ints: List[Int]): Int =
    ints match // A function that uses pattern matching to add up a list of integers
      case Nil         => 0 // The sum of the empty list is 0.
      case Cons(x, xs) =>
        x + sum(
          xs
        ) // The sum of a list starting with `x` is `x` plus the sum of the rest of the list.

  def product(doubles: List[Double]): Double = doubles match
    case Nil          => 1.0
    case Cons(0.0, _) => 0.0
    case Cons(x, xs)  => x * product(xs)

  def apply[A](as: A*): List[A] = // Variadic function syntax
    if as.isEmpty then Nil
    else Cons(as.head, apply(as.tail*))

  // Exercise 3.1: 以下の式 `result `の評価結果は何になるか? (推測してからREPLで確認してみよう)

  @annotation.nowarn // Scala gives a hint here via a warning, so let's disable that
  val result = List(1, 2, 3, 4, 5) match
    case Cons(x, Cons(2, Cons(4, _)))          => x
    case Nil                                   => 42
    case Cons(x, Cons(y, Cons(3, Cons(4, _)))) => x + y
    case Cons(h, t)                            => h + sum(t)
    case _                                     => 101

  def append[A](a1: List[A], a2: List[A]): List[A] =
    a1 match
      case Nil        => a2
      case Cons(h, t) => Cons(h, append(t, a2))

  def foldRight[A, B](
      as: List[A],
      acc: B,
      f: (A, B) => B
  ): B = // Utility functions
    as match
      case Nil         => acc
      case Cons(x, xs) => f(x, foldRight(xs, acc, f))

  def sumViaFoldRight(ns: List[Int]): Int =
    foldRight(ns, 0, (x, y) => x + y)

  def productViaFoldRight(ns: List[Double]): Double =
    foldRight(
      ns,
      1.0,
      _ * _
    ) // `_ * _` is more concise notation for `(x,y) => x * y`; see sidebar

  // Exercise 3.2: 先頭要素以外のリストを返す関数 `tail` を定義せよ。

  def tail[A](l: List[A]): List[A] = ???

  // Exercise 3.3: リストの先頭要素を別の値に置き換える関数 `setHead` を定義せよ。

  def setHead[A](l: List[A], h: A): List[A] = ???

  // Exercise 3.4: リストの先頭から `n` 個の要素を取り除く関数 `drop` を定義せよ。

  def drop[A](l: List[A], n: Int): List[A] = ???

  // Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数 `dropWhile` を定義せよ。

  def dropWhile[A](l: List[A], f: A => Boolean): List[A] = ???

  // Exercise 3.6: 末尾要素以外のリストを返す関数 `init` を定義せよ。

  def init[A](l: List[A]): List[A] = ???

  // Exercise 3.7: `foldRight` によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか?

  // Exercise 3.8: `foldRight` の引数 `acc` に `Nil` 、 `f` に `Cons(_, _)` を与えるとどのような結果が得られるか? (推測してからREPLで確認してみよう)

  // Exercise 3.9: リストの要素数を数える関数 `length` を定義せよ。

  def length[A](l: List[A]): Int = ???

  // Exercise 3.10: リストを左端から畳み込む `foldLeft` 関数を末尾再帰関数として定義せよ。

  def foldLeft[A, B](l: List[A], acc: B, f: (B, A) => B): B = ???

  // Exercise 3.11: `foldLeft` を用いて `sum`, `product`, `length` を定義せよ。

  def sumViaFoldLeft(ns: List[Int]): Int = ???

  def productViaFoldLeft(ns: List[Double]): Double = ???

  def lengthViaFoldLeft[A](l: List[A]): Int = ???

  // Exercise 3.12: `foldLeft` を用いてリストを逆順にする関数 `reverse` を定義せよ。

  def reverse[A](l: List[A]): List[A] = ???

  // Exercise 3.13: `foldLeft` を用いて `foldRight` を定義することは可能か? 可能であれば定義せよ。

  // Exercise 3.14: `foldRight` を用いて `append` を定義せよ。

  def appendViaFoldRight[A](l: List[A], r: List[A]): List[A] = ???

  // Exercise 3.15: `foldRight` を用いてリストのリストを1つのリストに連結する関数 `concat` を定義せよ。

  def concat[A](l: List[List[A]]): List[A] = ???

  // Exercise 3.16: `foldRight` を用いてリストの各要素に1を加える関数 `incrementEach` を定義せよ。

  def incrementEach(l: List[Int]): List[Int] = ???

  // Exercise 3.17: `foldRight` を用いてリストの各要素の数値を文字列に変換する関数 `doubleToString` を定義せよ。

  def doubleToString(l: List[Double]): List[String] = ???

  // Exercise 3.18: `doubleToString` を一般化して、リストの各要素に関数 `f` を適用する関数 `map` を定義せよ。

  def map[A, B](l: List[A], f: A => B): List[B] = ???

  // Exercise 3.19: リストの各要素を述語関数 `f` に従ってフィルタリングする関数 `filter` を定義せよ。

  def filter[A](as: List[A], f: A => Boolean): List[A] = ???

  // Exercise 3.20: リストの各要素を関数 `f` に適用して得られるリストのリストを1つのリストに連結する関数 `flatMap` を定義せよ。

  def flatMap[A, B](as: List[A], f: A => List[B]): List[B] = ???

  // Exercise 3.21: `flatMap` を用いて `filter` を定義せよ。

  def filterViaFlatMap[A](as: List[A], f: A => Boolean): List[A] = ???

  // Exercise 3.22: リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを返す関数 `addPairwise` を定義せよ。 `a`, `b` の長さが異なる場合、返すリストの長さは短いほうに一致する。

  def addPairwise(a: List[Int], b: List[Int]): List[Int] = ???

  // Exercise 3.23: `addPairwise` を一般化して、リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素に関数 `f` を適用して得られたリストを返す関数 `zipWith` を定義せよ。

  // def zipWith - TODO determine signature

  // Exercise 3.24: リスト `sup` の中にリスト `sub` が部分列として含まれているかどうかを判定する関数 `hasSubsequence` を定義せよ。
  // 例えば、 `List(1, 2, 3, 4)` は `List(1, 2)`, `List(2, 3)`, `List(4)` を部分列として含むが、 `List(1, 4)` は部分列として含まない。

  def hasSubsequence[A](sup: List[A], sub: List[A]): Boolean = ???
