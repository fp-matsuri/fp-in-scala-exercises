package fpinscala.exercises.parallelism

import java.util.concurrent.*

opaque type Par[A] = ExecutorService => Future[A]

object Par:
  // Exercise 7.2: ここでの並行計算 `Par` の内部表現がどのように定義されているか確認せよ。

  extension [A](pa: Par[A]) def run(s: ExecutorService): Future[A] = pa(s)

  def unit[A](a: A): Par[A] =
    es =>
      UnitFuture(
        a
      ) // `unit` is represented as a function that returns a `UnitFuture`, which is a simple implementation of `Future` that just wraps a constant value. It doesn't use the `ExecutorService` at all. It's always done and can't be cancelled. Its `get` method simply returns the value that we gave it.

  private case class UnitFuture[A](get: A) extends Future[A]:
    def isDone = true
    def get(timeout: Long, units: TimeUnit) = get
    def isCancelled = false
    def cancel(evenIfRunning: Boolean): Boolean = false

  // Exercise 7.1: 2つの並列計算 `Par` の結果を組み合わせるメソッド `map2` はどのようなシグネチャになるか考えよ(実装例は以下のとおり)。

  extension [A](pa: Par[A])
    def map2[B, C](pb: Par[B])(
        f: (A, B) => C
    ): Par[C] = // `map2` doesn't evaluate the call to `f` in a separate logical thread, in accord with our design choice of having `fork` be the sole function in the API for controlling parallelism. We can always do `fork(map2(a,b)(f))` if we want the evaluation of `f` to occur in a separate thread.
      es =>
        val af = pa(es)
        val bf = pb(es)
        UnitFuture(
          f(af.get, bf.get)
        ) // This implementation of `map2` does _not_ respect timeouts. It simply passes the `ExecutorService` on to both `Par` values, waits for the results of the Futures `af` and `bf`, applies `f` to them, and wraps them in a `UnitFuture`. In order to respect timeouts, we'd need a new `Future` implementation that records the amount of time spent evaluating `af`, then subtracts that time from the available time allocated for evaluating `bf`.

  extension [A](pa: Par[A])
    // Exercise 7.3: [java.util.concurrent.Future](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/Future.html)のタイムアウトが尊重されるように `map2` を実装せよ。

    def map2Timeouts[B, C](pb: Par[B])(f: (A, B) => C): Par[C] =
      ???

  def fork[A](
      a: => Par[A]
  ): Par[A] = // This is the simplest and most natural implementation of `fork`, but there are some problems with it--for one, the outer `Callable` will block waiting for the "inner" task to complete. Since this blocking occupies a thread in our thread pool, or whatever resource backs the `ExecutorService`, this implies that we're losing out on some potential parallelism. Essentially, we're using two threads when one should suffice. This is a symptom of a more serious problem with the implementation, and we will discuss this later in the chapter.
    es => es.submit(new Callable[A] { def call = a(es).get })

  // Exercise 7.8: 関数 `fork` は `fork(x) == x` が常に成り立つことが期待される。[java.util.concurrent.Executors](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/Executors.html)の各種 `ExecutorService` 実装に対して、この関数が常に期待通り振る舞うか検討せよ。

  // Exercise 7.9: この `fork` 実装では任意の固定サイズのスレッドプールでデッドロックが発生しうることを示せ。

  def lazyUnit[A](a: => A): Par[A] = fork(unit(a))

  // Exercise 7.4: `laziUnit` を用いて、任意の関数 `A => B` を受け取って非同期的に結果を返す関数に変換する関数 `asyncF` を実装せよ。

  def asyncF[A, B](f: A => B): A => Par[B] = ???

  extension [A](pa: Par[A])
    def map[B](f: A => B): Par[B] =
      pa.map2(unit(()))((a, _) => f(a))

    // Exercise 7.7: `y.map(id) == y` を前提に `y.map(g).map(f) == y.map(f compose g)` が成り立つことを証明せよ。

  def sortPar(parList: Par[List[Int]]) =
    parList.map(_.sorted)

  // Exercise 7.5: 関数 `sequence` を実装せよ。

  def sequence[A](pas: List[Par[A]]): Par[List[A]] = ???

  def parMap[A, B](ps: List[A])(f: A => B): Par[List[B]] = fork:
    val fbs: List[Par[B]] = ps.map(asyncF(f))
    sequence(fbs)

  // Exercise 7.6: 関数 `parFilter` を実装せよ。

  def parFilter[A](l: List[A])(f: A => Boolean): Par[List[A]] = ???

  def equal[A](e: ExecutorService)(p: Par[A], p2: Par[A]): Boolean =
    p(e).get == p2(e).get

  def delay[A](fa: => Par[A]): Par[A] =
    es => fa(es)

  def choice[A](cond: Par[Boolean])(t: Par[A], f: Par[A]): Par[A] =
    es =>
      if cond.run(es).get then
        t(es) // Notice we are blocking on the result of `cond`.
      else f(es)

  // Exercise 7.11: `choiceN` を実装し、それを用いて `choice` を実装せよ。

  def choiceN[A](n: Par[Int])(choices: List[Par[A]]): Par[A] = ???

  def choiceViaChoiceN[A](
      a: Par[Boolean]
  )(ifTrue: Par[A], ifFalse: Par[A]): Par[A] = ???

  // Exercise 7.12: `choiceMap` を実装せよ。

  def choiceMap[K, V](key: Par[K])(choices: Map[K, Par[V]]): Par[V] = ???

  // Exercise 7.13: `flatMap` を実装し、それを用いて `choice` と `choiceN` を実装せよ。

  /* `chooser` is usually called `flatMap` or `bind`. */
  extension [A](pa: Par[A]) def flatMap[B](choices: A => Par[B]): Par[B] = ???

  def choiceViaFlatMap[A](p: Par[Boolean])(f: Par[A], t: Par[A]): Par[A] = ???

  def choiceNViaFlatMap[A](p: Par[Int])(choices: List[Par[A]]): Par[A] = ???

  // Exercise 7.14: `join` を実装せよ。
  // また、 `flatMap` を用いて `join` を、 `join` を用いて `flatMap` をそれぞれ実装せよ。

  // see nonblocking implementation in `Nonblocking.scala`
  def join[A](a: Par[Par[A]]): Par[A] = ???

  def joinViaFlatMap[A](a: Par[Par[A]]): Par[A] = ???

  extension [A](pa: Par[A]) def flatMapViaJoin[B](f: A => Par[B]): Par[B] = ???

object Examples:
  import Par.*
  def sum(
      ints: IndexedSeq[Int]
  ): Int = // `IndexedSeq` is a superclass of random-access sequences like `Vector` in the standard library. Unlike lists, these sequences provide an efficient `splitAt` method for dividing them into two parts at a particular index.
    if ints.size <= 1 then
      ints.headOption.getOrElse(
        0
      ) // `headOption` is a method defined on all collections in Scala. We saw this function in chapter 3.
    else
      val (l, r) = ints.splitAt(
        ints.size / 2
      ) // Divide the sequence in half using the `splitAt` function.
      sum(l) + sum(
        r
      ) // Recursively sum both halves and add the results together.
