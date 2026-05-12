package fpinscala.exercises.datastructures

enum Tree[+A]:
  case Leaf(value: A)
  case Branch(left: Tree[A], right: Tree[A])

  def size: Int = this match
    case Leaf(_)      => 1
    case Branch(l, r) => 1 + l.size + r.size

  // Exercise 3.26: ツリーの深さを計算するメソッド `depth` を定義せよ。深さは、ルートから最も遠いリーフまでのパスの長さである。

  def depth: Int = ???

  // Exercise 3.27: ツリーの各リーフに関数 `f` を適用するメソッド `map` を定義せよ。

  def map[B](f: A => B): Tree[B] = ???

  // Exercise 3.28: ツリーのリーフの値を変換する関数 `f` とブランチの左右の値をまとめる関数 `g` を受け取ってツリーを畳み込むメソッド `fold` を定義せよ。
  // また、 `fold` を用いて `size` 、 `depth` 、 `map` を定義せよ。

  def fold[B](f: A => B, g: (B, B) => B): B = ???

  def sizeViaFold: Int = ???

  def depthViaFold: Int = ???

  def mapViaFold[B](f: A => B): Tree[B] = ???

object Tree:

  def size[A](t: Tree[A]): Int = t match
    case Leaf(_)      => 1
    case Branch(l, r) => 1 + size(l) + size(r)

  extension (t: Tree[Int]) def firstPositive: Int = ???

  // Exercise 3.25: ツリーのリーフの最大値を計算する拡張メソッド `maximum` を定義せよ。
  // また、 `fold` を用いて `maximum` を定義せよ。

  extension (t: Tree[Int]) def maximum: Int = ???

  extension (t: Tree[Int]) def maximumViaFold: Int = ???
