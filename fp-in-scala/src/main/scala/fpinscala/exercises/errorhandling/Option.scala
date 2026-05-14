package fpinscala.exercises.errorhandling

// Hide std library `Option` since we are writing our own in this chapter
import scala.{Option as _, Some as _, None as _}

enum Option[+A]:
  case Some(get: A)
  case None

  // Exercise 4.1: メソッド `map` 、 `getOrElse` 、 `flatMap` 、 `orElse` 、 `filter` を実装せよ。
  // `getOrElse` は `Some` ならその中身の値を返し、 `None` なら引数のデフォルト値を返す。
  // `orElse` は `Some` ならそのまま返し、 `None` なら引数のOption値を返す。

  def map[B](f: A => B): Option[B] = ???

  def getOrElse[B >: A](default: => B): B = ???

  def flatMap[B](f: A => Option[B]): Option[B] = ???

  def orElse[B >: A](ob: => Option[B]): Option[B] = ???

  def filter(f: A => Boolean): Option[A] = ???

object Option:

  def failingFn(i: Int): Int =
    val y: Int = throw new Exception(
      "fail!"
    ) // `val y: Int = ...` declares `y` as having type `Int`, and sets it equal to the right hand side of the `=`.
    try
      val x = 42 + 5
      x + y
    catch
      case e: Exception =>
        43 // A `catch` block is just a pattern matching block like the ones we've seen. `case e: Exception` is a pattern that matches any `Exception`, and it binds this value to the identifier `e`. The match returns the value 43.

  def failingFn2(i: Int): Int =
    try
      val x = 42 + 5
      x + ((throw new Exception(
        "fail!"
      )): Int) // A thrown Exception can be given any type; here we're annotating it with the type `Int`
    catch case e: Exception => 43

  def mean(xs: Seq[Double]): Option[Double] =
    if xs.isEmpty then None
    else Some(xs.sum / xs.length)

  // Exercise 4.2: 分散(平均からの偏差の2乗の平均)を計算する関数 `variance` を定義せよ。

  def variance(xs: Seq[Double]): Option[Double] = ???

  // Exercise 4.3: 2つのOption値がともに `Some` なら、2つの値に関数 `f` を適用する関数 `map2` を定義せよ。
  // どちらかが `None` なら結果も `None` になる。

  def map2[A, B, C](a: Option[A], b: Option[B])(f: (A, B) => C): Option[C] = ???

  // Exercise 4.4: OptionのリストをリストのOptionに変換する関数 `sequence` を定義せよ。

  def sequence[A](as: List[Option[A]]): Option[List[A]] = ???

  // Exercise 4.5: リストの要素に関数 `f` を適用した結果をリストのOptionに変換する関数 `traverse` を定義せよ。

  def traverse[A, B](as: List[A])(f: A => Option[B]): Option[List[B]] = ???
