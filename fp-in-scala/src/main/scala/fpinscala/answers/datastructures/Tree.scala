package fpinscala.answers.datastructures

enum Tree[+A]:
  case Leaf(value: A)
  case Branch(left: Tree[A], right: Tree[A])

  def size: Int = this match
    case Leaf(_)      => 1
    case Branch(l, r) => 1 + l.size + r.size

  // Exercise 3.26: ツリーの深さを計算するメソッド `depth` を定義せよ。深さは、ルートから最も遠いリーフまでのパスの長さである。

  def depth: Int = this match
    case Leaf(_)      => 0
    case Branch(l, r) => 1 + (l.depth.max(r.depth))

  // Exercise 3.27: ツリーの各リーフに関数 `f` を適用するメソッド `map` を定義せよ。

  def map[B](f: A => B): Tree[B] = this match
    case Leaf(a)      => Leaf(f(a))
    case Branch(l, r) => Branch(l.map(f), r.map(f))

  // Exercise 3.28-1: ツリーのリーフの値を変換する関数 `f` とブランチの左右の値をまとめる関数 `g` を受け取ってツリーを畳み込むメソッド `fold` を定義せよ。
  // また、 `fold` を用いて `size` 、 `depth` 、 `map` を定義せよ。

  /*
  Like `foldRight` for lists, `fold` receives a "handler" for each of the data constructors of the type, and recursively
  accumulates some value using these handlers. As with `foldRight`, `t.fold(Leaf(_))(Branch(_,_)) == t`, and we can use
  this function to implement just about any recursive function that would otherwise be defined by pattern matching.
   */
  def fold[B](f: A => B, g: (B, B) => B): B = this match
    case Leaf(a)      => f(a)
    case Branch(l, r) => g(l.fold(f, g), r.fold(f, g))

  def sizeViaFold: Int =
    fold(a => 1, 1 + _ + _)

  def depthViaFold: Int =
    fold(a => 0, (d1, d2) => 1 + (d1 max d2))

  def mapViaFold[B](f: A => B): Tree[B] =
    fold(a => Leaf(f(a)), Branch(_, _))

object Tree:

  def size[A](t: Tree[A]): Int = t match
    case Leaf(_)      => 1
    case Branch(l, r) => 1 + size(l) + size(r)

  extension (t: Tree[Int])
    def firstPositive: Int = t match
      case Leaf(i)      => i
      case Branch(l, r) =>
        val lpos = l.firstPositive
        if lpos > 0 then lpos else r.firstPositive

  // Exercise 3.25: ツリーのリーフの最大値を計算する拡張メソッド `maximum` を定義せよ。

  /*
  We're using the method `max` that exists on all `Int` values rather than an explicit `if` expression.

  Note how similar the implementation is to `size`. We'll abstract out the common pattern in a later exercise.
   */
  extension (t: Tree[Int])
    def maximum: Int = t match
      case Leaf(n)      => n
      case Branch(l, r) => l.maximum.max(r.maximum)

  // Exercise 3.28-2: `fold` を用いて `maximum` を定義せよ。

  extension (t: Tree[Int])
    def maximumViaFold: Int =
      t.fold(a => a, _ max _)
