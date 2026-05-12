package fpinscala.exercises.state

trait RNG:
  def nextInt: (Int, RNG) // Should generate a random `Int`. We'll later define other functions in terms of `nextInt`.

object RNG:
  // NB - this was called SimpleRNG in the book text

  case class Simple(seed: Long) extends RNG:
    def nextInt: (Int, RNG) =
      val newSeed =
        (seed * 0x5deece66dL + 0xbL) & 0xffffffffffffL // `&` is bitwise AND. We use the current seed to generate a new seed.
      val nextRNG = Simple(
        newSeed
      ) // The next state, which is an `RNG` instance created from the new seed.
      val n =
        (newSeed >>> 16).toInt // `>>>` is right binary shift with zero fill. The value `n` is our new pseudo-random integer.
      (
        n,
        nextRNG
      ) // The return value is a tuple containing both a pseudo-random integer and the next `RNG` state.

  type Rand[+A] = RNG => (A, RNG)

  val int: Rand[Int] = _.nextInt

  def unit[A](a: A): Rand[A] =
    rng => (a, rng)

  def map[A, B](s: Rand[A])(f: A => B): Rand[B] =
    rng =>
      val (a, rng2) = s(rng)
      (f(a), rng2)

  // Exercise 6.1: 非負整数をランダム生成する関数 `nonNegativeInt` を実装せよ。

  def nonNegativeInt(rng: RNG): (Int, RNG) = ???

  // Exercise 6.2: 0以上1未満の浮動小数点数をランダム生成する関数 `double` を実装せよ。

  def double(rng: RNG): (Double, RNG) = ???

  // Exercise 6.3: 整数と浮動小数点数の組をランダム生成する関数 `intDouble` と `doubleInt` を実装せよ。
  // また、浮動小数点数の3つ組をランダム生成する関数 `double3` を実装せよ。

  def intDouble(rng: RNG): ((Int, Double), RNG) = ???

  def doubleInt(rng: RNG): ((Double, Int), RNG) = ???

  def double3(rng: RNG): ((Double, Double, Double), RNG) = ???

  // Exercise 6.4: 引数で指定された要素数の整数リストをランダム生成する関数 `ints` を実装せよ。

  def ints(count: Int)(rng: RNG): (List[Int], RNG) = ???

  // Exercise 6.5: `map` を用いて `double` を実装せよ。

  // Exercise 6.6: 関数 `map2` を実装せよ。

  def map2[A, B, C](ra: Rand[A], rb: Rand[B])(f: (A, B) => C): Rand[C] = ???

  // Exercise 6.7: 関数 `sequence` を実装せよ。

  def sequence[A](rs: List[Rand[A]]): Rand[List[A]] = ???

  // Exercise 6.8: 関数 `flatMap` を実装せよ。

  def flatMap[A, B](r: Rand[A])(f: A => Rand[B]): Rand[B] = ???

  // Exercise 6.9: `flatMap` を用いて `map`, `map2` を実装せよ。

  def mapViaFlatMap[A, B](r: Rand[A])(f: A => B): Rand[B] = ???

  def map2ViaFlatMap[A, B, C](ra: Rand[A], rb: Rand[B])(
      f: (A, B) => C
  ): Rand[C] = ???

opaque type State[S, +A] = S => (A, S)

object State:
  extension [S, A](underlying: State[S, A])
    def run(s: S): (A, S) = underlying(s)

    // Exercise 6.10: 拡張メソッド `map`, `map2`, `flatMap` を実装せよ。
    // また、関数 `unit`, `sequence`, `traverse` を実装せよ。

    def map[B](f: A => B): State[S, B] =
      ???

    def map2[B, C](sb: State[S, B])(f: (A, B) => C): State[S, C] =
      ???

    def flatMap[B](f: A => State[S, B]): State[S, B] =
      ???

  def apply[S, A](f: S => (A, S)): State[S, A] = f

  def modify[S](f: S => S): State[S, Unit] =
    for
      s <- get // Gets the current state and assigns it to `s`.
      _ <- set(f(s)) // Sets the new state to `f` applied to `s`.
    yield ()

  def get[S]: State[S, S] = s => (s, s)

  def set[S](s: S): State[S, Unit] = _ => ((), s)

// Exercise 6.11: Stateを用いて以下のルールを満たすキャンディ販売機の振る舞いをシミュレートする関数 `simulateMachine` を実装せよ。
// `simulateMachine` は入力リストを受け取って販売機の最終的なキャンディの個数とコインの枚数のペアを返す。
// ルール:
//   - 販売機がロックされている(`locked = true`)とき、ノブを回し(Input.Turn)ても販売機は反応しない
//   - 販売機がロックされている(`locked = true`)とき、コインを投入する(Input.Coin)と販売機のロックが外れてコインが1枚増える
//   - 販売機がロックされていない(`locked = false`)とき、ノブを回す(Input.Turn)と販売機のロックが掛かってキャンディが1個減る
//   - 販売機がロックされていない(`locked = false`)とき、コインを投入し(Input.Coin)ても販売機は反応しない
//   - 販売機にキャンディが残っていない(`candies = 0`)とき、コインを投入し(Input.Coin)てもノブを回し(Input.Turn)ても販売機は反応しない

enum Input:
  case Coin, Turn

case class Machine(locked: Boolean, candies: Int, coins: Int)

object Candy:
  def simulateMachine(inputs: List[Input]): State[Machine, (Int, Int)] = ???
