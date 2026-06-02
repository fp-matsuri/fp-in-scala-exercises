package fpinscala.answers.testing

import fpinscala.answers.state.*
import fpinscala.answers.parallelism.*
import fpinscala.answers.parallelism.Par
import java.util.concurrent.{Executors, ExecutorService}
import annotation.targetName

import Gen.*
import Prop.*
import Prop.Result.{Passed, Falsified, Proved}

// Exercise 8.1: 関数 `sum: List[Int] => Int` について常に成り立つプロパティ(性質)を検討せよ。

/*
 * 例えば以下のプロパティが考えられる:
 * - 空リストの和は0 -- `sum(Nil) == 0`
 *  要素がすべて `x` のリストの和はリストの要素数の `x` 倍 -- `sum(List.fill(n)(x)) == n * x`
 * - 任意のリスト `xs` について、その和は `xs.reverse` の和に一致する -- `sum(xs) == sum(xs.reverse)`
 *     - これは加法が可換(commutative, 交換法則を満たす)なため成り立つ
 * - 任意のリスト `xs` について、2つのリストに分割してそれぞれの和を計算してから足し合わせたものは `xs` の和に一致する
 *     - これは加法が結合的(associative, 結合法則を満たす)なため成り立つ
 * - 1, 2, 3...`n` を要素とするリストの和は `n*(n+1)/2`
 */

// Exercise 8.2: `List[Int]` の最大値を返す関数について常に成り立つプロパティ(性質)を見つけよ。

/*
 * 例えば以下のプロパティが考えられる:
 * - 空リストの最大値は未定義のためエラー
 * - 要素が1つだけのリストの最大値はその要素
 * - 要素がすべて `x` のリストの最大値は `x`
 * - リストの最大値はそのリストの要素
 * - リストの最大値はそのリストのいずれの要素より大きいまたは等しい
 */

// Exercise 8.3: プロパティを以下のように表現する場合のメソッド `&&` を実装せよ。
/*
trait Prop:
  self =>
  def check: Boolean
  def &&(that: Prop): Prop =
    new Prop:
      def check = self.check && that.check
 */

opaque type Prop = (MaxSize, TestCases, RNG) => Result

object Prop:
  opaque type SuccessCount = Int
  object SuccessCount:
    extension (x: SuccessCount) def toInt: Int = x
    def fromInt(x: Int): SuccessCount = x

  opaque type TestCases = Int
  object TestCases:
    extension (x: TestCases) def toInt: Int = x
    def fromInt(x: Int): TestCases = x

  opaque type MaxSize = Int
  object MaxSize:
    extension (x: MaxSize) def toInt: Int = x
    def fromInt(x: Int): MaxSize = x

  opaque type FailedCase = String
  object FailedCase:
    extension (f: FailedCase) def string: String = f
    def fromString(s: String): FailedCase = s

  enum Result:
    case Passed
    case Falsified(failure: FailedCase, successes: SuccessCount)
    case Proved

    def isFalsified: Boolean = this match
      case Passed          => false
      case Falsified(_, _) => true
      case Proved          => false

  /* Produce an infinite random lazy list from a `Gen` and a starting `RNG`. */
  def randomLazyList[A](g: Gen[A])(rng: RNG): LazyList[A] =
    LazyList.unfold(rng)(rng => Some(g.run(rng)))

  def forAll[A](as: Gen[A])(f: A => Boolean): Prop = Prop: (n, rng) =>
    randomLazyList(as)(rng)
      .zip(LazyList.from(0))
      .take(n)
      .map:
        case (a, i) =>
          try if f(a) then Passed else Falsified(a.toString, i)
          catch case e: Exception => Falsified(buildMsg(a, e), i)
      .find(_.isFalsified)
      .getOrElse(Passed)

  @targetName("forAllSized")
  def forAll[A](g: SGen[A])(f: A => Boolean): Prop =
    (max, n, rng) =>
      val casesPerSize = (n.toInt - 1) / max.toInt + 1
      val props: LazyList[Prop] =
        LazyList
          .from(0)
          .take((n.toInt min max.toInt) + 1)
          .map(i => forAll(g(i))(f))
      val prop: Prop =
        props
          .map[Prop](p => (max, n, rng) => p(max, casesPerSize, rng))
          .toList
          .reduce(_ && _)
      prop(max, n, rng)

  // String interpolation syntax. A string starting with `s"` can refer to
  // a Scala value `v` as `$v` or `${v}` in the string.
  // This will be expanded to `v.toString` by the Scala compiler.
  def buildMsg[A](s: A, e: Exception): String =
    s"test case: $s\n" +
      s"generated an exception: ${e.getMessage}\n" +
      s"stack trace:\n ${e.getStackTrace.mkString("\n")}"

  def apply(f: (TestCases, RNG) => Result): Prop =
    (_, n, rng) => f(n, rng)

  extension (self: Prop)
    // Exercise 8.9: `&&`, `||` を実装せよ。

    def &&(that: Prop): Prop =
      (max, n, rng) =>
        self.tag("and-left")(max, n, rng) match
          case Passed | Proved => that.tag("and-right")(max, n, rng)
          case x               => x

    def ||(that: Prop): Prop =
      (max, n, rng) =>
        self.tag("or-left")(max, n, rng) match
          // In case of failure, run the other prop.
          case Falsified(msg, _) =>
            that.tag("or-right").tag(msg.string)(max, n, rng)
          case x => x

    /* This is rather simplistic - in the event of failure, we simply wrap
     * the failure message with the given message.
     */
    def tag(msg: String): Prop =
      (max, n, rng) =>
        self(max, n, rng) match
          case Falsified(e, c) =>
            Falsified(FailedCase.fromString(s"$msg($e)"), c)
          case x => x

    def check(
        maxSize: MaxSize = 100,
        testCases: TestCases = 100,
        rng: RNG = RNG.Simple(System.currentTimeMillis)
    ): Result =
      self(maxSize, testCases, rng)

    def run(
        maxSize: MaxSize = 100,
        testCases: TestCases = 100,
        rng: RNG = RNG.Simple(System.currentTimeMillis)
    ): Unit =
      self(maxSize, testCases, rng) match
        case Falsified(msg, n) =>
          println(s"! Falsified after $n passed tests:\n $msg")
        case Passed =>
          println(s"+ OK, passed $testCases tests.")
        case Proved =>
          println("+ OK, proved property.")

  val executor: ExecutorService = Executors.newCachedThreadPool

  val p1 = Prop.forAll(Gen.unit(Par.unit(1)))(pi =>
    pi.map(_ + 1).run(executor).get == Par.unit(2).run(executor).get
  )

  def verify(p: => Boolean): Prop =
    (_, _, _) => if p then Passed else Falsified("()", 0)

  // Exercise 8.15: プロパティ `verify` ではBoolean値の2択であるため振る舞いを網羅的に確かめるのは容易であるのに対して、
  // プロパティ `forAll` ではジェネレータが生成する値の定義域が有限である(もしくは無限であってもサイズ付きのジェネレータである)場合に網羅的に確かめることができる。
  // 我々が実装しているプロパティベーステストライブラリにそのような網羅的なチェックを組み込むにはどのようにすればよいか検討せよ。

  // 実装例: ./Exhaustive.scala

  val p2 = verify:
    val p = Par.unit(1).map(_ + 1)
    val p2 = Par.unit(2)
    p.run(executor).get == p2.run(executor).get

  def equal[A](p: Par[A], p2: Par[A]): Par[Boolean] =
    p.map2(p2)(_ == _)

  val p3 = verify:
    equal(
      Par.unit(1).map(_ + 1),
      Par.unit(2)
    ).run(executor).get

  val p4 = forAll(Gen.smallInt): i =>
    equal(
      Par.unit(i).map(_ + 1),
      Par.unit(i + 1)
    ).run(executor).get

  val executors: Gen[ExecutorService] = weighted(
    choose(1, 4).map(Executors.newFixedThreadPool) -> .75,
    unit(Executors.newCachedThreadPool) -> .25
  ) // `a -> b` is syntax sugar for `(a, b)`

  def forAllPar[A](g: Gen[A])(f: A => Par[Boolean]): Prop =
    forAll(executors ** g)((s, a) => f(a).run(s).get)

  def verifyPar(p: Par[Boolean]): Prop =
    forAllPar(Gen.unit(()))(_ => p)

  def forAllPar2[A](g: Gen[A])(f: A => Par[Boolean]): Prop =
    forAll(executors ** g)((s, a) => f(a).run(s).get)

  def forAllPar3[A](g: Gen[A])(f: A => Par[Boolean]): Prop =
    forAll(executors ** g):
      case s ** a => f(a).run(s).get

  val gpy: Gen[Par[Int]] = Gen.choose(0, 10).map(Par.unit(_))
  val p5 = forAllPar(gpy)(py => equal(py.map(y => y), py))

  // Exercise 8.16: ジェネレータ `gpy` をネストした複数の並列計算を生成するように改良せよ。

  val gpy2: Gen[Par[Int]] = choose(-100, 100)
    .listOfN(choose(0, 20))
    .map(ys =>
      ys.foldLeft(Par.unit(0))((p, y) => Par.fork(p.map2(Par.unit(y))(_ + _)))
    )

  extension [A](self: List[A])
    def parTraverse[B](f: A => Par[B]): Par[List[B]] =
      self.foldRight(Par.unit(Nil: List[B]))((a, pacc) =>
        Par.fork(f(a).map2(pacc)(_ :: _))
      )

  val gpy3: Gen[Par[Int]] =
    choose(-100, 100)
      .listOfN(choose(0, 20))
      .map(ys => ys.parTraverse(Par.unit).map(_.sum))

  // Exercise 8.17: Chapter 7 (parallelism)の `fork` に関するプロパティ `fork(x) == x` を実装せよ。

  val forkProp = Prop.forAllPar(gpy2)(y => equal(Par.fork(y), y))

end Prop

opaque type Gen[+A] = State[RNG, A]

object Gen:
  extension [A](self: Gen[A])
    def map[B](f: A => B): Gen[B] =
      State.map(self)(f)

    def map2[B, C](that: Gen[B])(f: (A, B) => C): Gen[C] =
      State.map2(self)(that)(f)

    // Exercise 8.6-1: `flatMap` を実装せよ。

    def flatMap[B](f: A => Gen[B]): Gen[B] =
      State.flatMap(self)(f)

    /* A method alias for the function we wrote earlier. */
    def listOfN(size: Int): Gen[List[A]] =
      Gen.listOfN(size, self)

    // Exercise 8.6-2: `flatMap` を用いて、サイズを動的に生成する `listOfN` を実装せよ。

    def listOfN(size: Gen[Int]): Gen[List[A]] =
      size.flatMap(listOfN)

    // Exercise 8.12: 指定サイズのリストを生成する `SGen` を返す関数 `list` を実装せよ。

    def list: SGen[List[A]] =
      n => listOfN(n)

    // Exercise 8.13: 空でないリストを生成する `SGen` を返す関数 `nonEmptyList` を実装せよ。

    def nonEmptyList: SGen[List[A]] =
      n => listOfN(n.max(1))

    // Exercise 8.10: サイズの引数を無視して `SGen` に変換する関数 `unsized` を実装せよ。

    def unsized: SGen[A] = _ => self

    @targetName("product")
    def **[B](gb: Gen[B]): Gen[(A, B)] =
      map2(gb)((_, _))

  def apply[A](s: State[RNG, A]): Gen[A] = s

  // Exercise 8.5-1: `unit`, `boolean` を実装せよ。

  def unit[A](a: => A): Gen[A] =
    State.unit(a)

  val boolean: Gen[Boolean] =
    State(RNG.boolean)

  // Exercise 8.4: `start` から `stopExclusive` までの範囲の整数をランダム生成する関数 `choose` を実装せよ。

  def choose(start: Int, stopExclusive: Int): Gen[Int] =
    State(RNG.nonNegativeInt).map(n => start + n % (stopExclusive - start))

  // Exercise 8.5-2: `listOfN` を実装せよ。

  def listOfN[A](n: Int, g: Gen[A]): Gen[List[A]] =
    State.sequence(List.fill(n)(g))

  def listOfN_1[A](n: Int, g: Gen[A]): Gen[List[A]] =
    List.fill(n)(g).foldRight(unit(List[A]()))((a, b) => a.map2(b)(_ :: _))

  val double: Gen[Double] = Gen(State(RNG.double))
  val int: Gen[Int] = Gen(State(RNG.int))

  def choose(i: Double, j: Double): Gen[Double] =
    State(RNG.double).map(d => i + d * (j - i))

  /* Basic idea is to add 1 to the result of `choose` if it is of the wrong
   * parity, but we require some special handling to deal with the maximum
   * integer in the range.
   */
  def even(start: Int, stopExclusive: Int): Gen[Int] =
    choose(
      start,
      if stopExclusive % 2 == 0 then stopExclusive - 1 else stopExclusive
    ).map(n => if n % 2 != 0 then n + 1 else n)

  def odd(start: Int, stopExclusive: Int): Gen[Int] =
    choose(
      start,
      if stopExclusive % 2 != 0 then stopExclusive - 1 else stopExclusive
    ).map(n => if n % 2 == 0 then n + 1 else n)

  def sameParity(from: Int, to: Int): Gen[(Int, Int)] =
    for
      i <- choose(from, to)
      j <- if i % 2 == 0 then even(from, to) else odd(from, to)
    yield (i, j)

  // Exercise 8.7: 2つのジェネレータから等しい確率で一方の値を取り出すようにジェネレータをまとめる `union` を実装せよ。

  def union[A](g1: Gen[A], g2: Gen[A]): Gen[A] =
    boolean.flatMap(b => if b then g1 else g2)

  // Exercise 8.8: 2つのジェネレータから重み付きの確率で一方の値を取り出すようにジェネレータをまとめる `weighted` を実装せよ。

  def weighted[A](g1: (Gen[A], Double), g2: (Gen[A], Double)): Gen[A] =
    /* The probability we should pull from `g1`. */
    val g1Threshold = g1._2.abs / (g1._2.abs + g2._2.abs)
    State(RNG.double).flatMap(d => if d < g1Threshold then g1._1 else g2._1)

  /* Not the most efficient implementation, but it's simple.
   * This generates ASCII strings.
   */
  def stringN(n: Int): Gen[String] =
    listOfN(n, choose(0, 127)).map(_.map(_.toChar).mkString)

  val string: SGen[String] = SGen(stringN)

  val smallInt = Gen.choose(-10, 10)

  val maxProp = Prop.forAll(smallInt.list): l =>
    val max = l.max
    l.forall(_ <= max)

  val maxProp1 = Prop.forAll(smallInt.nonEmptyList): l =>
    val max = l.max
    l.forall(_ <= max)

  // Exercise 8.14: [List.sorted](https://www.scala-lang.org/api/current/scala/collection/immutable/List.html#sorted-ffffff34)の振る舞いに関するプロパティを実装せよ。

  val sortedProp = Prop.forAll(smallInt.list): l =>
    val ls = l.sorted
    val ordered = l.isEmpty || ls.zip(ls.tail).forall((a, b) => a <= b)
    ordered && l.forall(ls.contains) && ls.forall(l.contains)

  object `**`:
    def unapply[A, B](p: (A, B)) = Some(p)

  def genStringIntFn(g: Gen[Int]): Gen[String => Int] =
    g.map(i => s => i)

  def genStringFn[A](g: Gen[A]): Gen[String => A] =
    State[RNG, String => A]: rng =>
      val (seed, rng2) =
        rng.nextInt // we still use `rng` to produce a seed, so we get a new function each time
      val f =
        (s: String) => g.run(RNG.Simple(seed.toLong ^ s.hashCode.toLong))._1
      (f, rng2)

end Gen

opaque type SGen[+A] = Int => Gen[A]

object SGen:
  extension [A](self: SGen[A])

    def apply(n: Int): Gen[A] = self(n)

    // Exercise 8.11: `map`, `flatMap` を実装せよ。

    def map[B](f: A => B): SGen[B] =
      self(_).map(f)

    def flatMap[B](f: A => SGen[B]): SGen[B] =
      n => self(n).flatMap(f(_)(n))

    def **[B](s2: SGen[B]): SGen[(A, B)] =
      n => Gen.**(apply(n))(s2(n))

  def apply[A](f: Int => Gen[A]): SGen[A] = f

// Exercise 8.18: 高階関数[List.takeWhile](https://www.scala-lang.org/api/current/scala/collection/immutable/List.html#takeWhile-5a1)に関するプロパティを見つけよ。

/*
 * 任意のリスト `as: List[A]`, 述語関数 `p: A => Boolean` について、例えば以下のプロパティが考えられる:
 * - `as.takeWhile(p).forall(p) == true`
 * - `as.size > as.takeWhile(p).size` のとき `!p(as(as.takeWhile(p).size))`
 * - `as.takeWhile(p) ++ as.dropWhile(p) == as`
 */

// Exercise 8.19: 引数を何らかの形で利用して戻り値を決めるような関数のジェネレータを実装したい。我々のライブラリをどのように拡張すれば実現できそうか検討せよ。

// 例えば `Gen.genStringFn` のようにジェネレータを実装することができ、一般化すると以下のようになる。

opaque type Cogen[-A] = (A, RNG) => RNG

object Cogen:
  def fn[A, B](in: Cogen[A], out: Gen[B]): Gen[A => B] =
    State[RNG, A => B]: rng =>
      val (seed, rng2) = rng.nextInt
      val f = (a: A) => out.run(in(a, rng2))._1
      (f, rng2)

  def cogenInt: Cogen[Int] = (i, rng) =>
    val (seed, rng2) = rng.nextInt
    RNG.Simple(seed.toLong ^ i.toLong)

  // We can now write properties that depend on arbitrary functions
  def takeWhilePropInt =
    forAll(Gen.int.list ** fn(cogenInt, Gen.boolean).unsized)((ys, f) =>
      ys.takeWhile(f).forall(f)
    )

  // And we can further generalize those properties to be parameterized by types which are not relevant
  def takeWhileProp[A](ga: Gen[A], ca: Cogen[A]) =
    forAll(ga.list ** fn(ca, Gen.boolean).unsized)((ys, f) =>
      ys.takeWhile(f).forall(f)
    )

// Exercise 8.20: 我々のライブラリを利用して、例えば以下のような課題に取り組んでみよ。
// - List/LazyListのtake, drop, filter, unfoldなどのメソッドに関するプロパティを実装する
// - Treeを生成するサイズ付きジェネレータを実装し、foldメソッドに関するプロパティで利用する
// - Option/Eitherのsequenceに関するプロパティを実装する

// 解答例なし(自由に試してみよう)
