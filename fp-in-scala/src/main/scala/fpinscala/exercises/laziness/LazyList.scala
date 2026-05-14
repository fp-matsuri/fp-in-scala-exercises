package fpinscala.exercises.laziness

enum LazyList[+A]:
  case Empty
  case Cons(h: () => A, t: () => LazyList[A])

  // Exercise 5.1: 遅延リストをリストに変換するメソッド `toList` を定義せよ。

  def toList: List[A] = ???

  def foldRight[B](z: => B)(
      f: (A, => B) => B
  ): B = // The arrow `=>` in front of the argument type `B` means that the function `f` takes its second argument by name and may choose not to evaluate it.
    this match
      case Cons(h, t) =>
        f(
          h(),
          t().foldRight(z)(f)
        ) // If `f` doesn't evaluate its second argument, the recursion never occurs.
      case _ => z

  def exists(p: A => Boolean): Boolean =
    foldRight(false)((a, b) =>
      p(a) || b
    ) // Here `b` is the unevaluated recursive step that folds the tail of the lazy list. If `p(a)` returns `true`, `b` will never be evaluated and the computation terminates early.

  @annotation.tailrec
  final def find(f: A => Boolean): Option[A] = this match
    case Empty      => None
    case Cons(h, t) => if (f(h())) Some(h()) else t().find(f)

  // Exercise 5.2: 遅延リストの先頭から最初の `n` 要素を返すメソッド `take` 、先頭から最初の `n` 要素をスキップするメソッド `drop` を定義せよ。

  def take(n: Int): LazyList[A] = ???

  def drop(n: Int): LazyList[A] = ???

  // Exercise 5.3: 遅延リストの先頭から条件を満たす限り続けて要素を返すメソッド `takeWhile` を定義せよ。

  def takeWhile(p: A => Boolean): LazyList[A] = ???

  // Exercise 5.4: 遅延リストのすべての要素が条件を満たすかどうかを判定するメソッド `forAll` を定義せよ。

  def forAll(p: A => Boolean): Boolean = ???

  // Exercise 5.5: `foldRight` を用いて `takeWhile` を実装せよ。

  // Exercise 5.6: `foldRight` を用いて先頭要素を返すメソッド `headOption` を実装せよ。

  def headOption: Option[A] = ???

  // Exercise 5.7: `foldRight` を用いて `map`, `filter`, `append`, `flatMap` を実装せよ。

  // Exercise 5.13: `unfold` を用いて `map`, `take`, `takeWhile`, `zipWith`, `zipAll` を実装せよ。
  // `zipAll` は2つの遅延リストが両方とも尽きるまでそれぞれ先頭から順に取り出して対応する要素をペアにして返す。

  def zipAll[B](
      that: LazyList[B]
  ): LazyList[(Option[A], Option[B])] = ???

  // Exercise 5.14: 定義済みのメソッドを用いて遅延リストが `prefix` で始まるかどうか判定するメソッド `startsWith` を定義せよ。

  def startsWith[B](prefix: LazyList[B]): Boolean = ???

  // Exercise 5.15: `unfold` を用いて遅延リストに `tail` を繰り返し適用した結果を返すメソッド `tails` を定義せよ。
  // 例えば `LazyList(1, 2, 3).tails` は `LazyList(LazyList(1, 2, 3), LazyList(2, 3), LazyList(3), LazyList())` を返す。

  def tails: LazyList[LazyList[A]] = ???

  // Exercise 5.16: `tails` を一般化して、 `foldRight` の累積値を要素とする遅延リストを返すメソッド `scanRight` を定義せよ。

object LazyList:
  def cons[A](hd: => A, tl: => LazyList[A]): LazyList[A] =
    lazy val head = hd
    lazy val tail = tl
    Cons(() => head, () => tail)

  def empty[A]: LazyList[A] = Empty

  def apply[A](as: A*): LazyList[A] =
    if as.isEmpty then empty
    else cons(as.head, apply(as.tail*))

  val ones: LazyList[Int] = LazyList.cons(1, ones)

  // Exercise 5.8: 任意の値を無限に繰り返す遅延リストを生成する関数 `continually` を定義せよ。

  def continually[A](a: A): LazyList[A] = ???

  // Exercise 5.9: `n` から1ずつ増える無限の遅延リストを生成する関数 `from` を定義せよ。

  def from(n: Int): LazyList[Int] = ???

  // Exercise 5.10: フィボナッチ数の無限の遅延リストを生成する関数 `fibs` を定義せよ。

  lazy val fibs: LazyList[Int] = ???

  // Exercise 5.11: は初期状態 `state` 、状態から次の要素と次の状態を返す関数 `f` を受け取って遅延リストを生成する一般的な関数 `unfold` を定義せよ。

  def unfold[A, S](state: S)(f: S => Option[(A, S)]): LazyList[A] = ???

  // Exercise 5.12: `unfold` を用いて `fibs`, `from`, `continually`, `ones` を実装せよ。

  lazy val fibsViaUnfold: LazyList[Int] = ???

  def fromViaUnfold(n: Int): LazyList[Int] = ???

  def continuallyViaUnfold[A](a: A): LazyList[A] = ???

  lazy val onesViaUnfold: LazyList[Int] = ???
