pub mod FpInFlix.Exercises.State.Rng {
   pub enum Rng(Int64) with Eq, ToString

   pub def nextInt(rng: Rng): (Int32, Rng) =
       let Rng(seed) = rng;
       // 現在のシード値から新たなシード値を生成する(線形合同法による)
       let newSeed = Int64.bitwiseAnd(seed * 25214903917i64 + 11i64, 281474976710655i64);
       let nextRng = Rng(newSeed);
       let n = Int64.rightShift(newSeed, 16) |> Int64.truncateToInt32;
       // 戻り値は擬似乱数の整数と次のシード値のタプル
       (n, nextRng)

    pub type alias Rand[a] = Rng -> (a, Rng)

    pub def int(): Rand[Int32] =
        rng -> nextInt(rng)

    pub def unit(a: a): Rand[a] =
        rng -> (a, rng)

    pub def map(f: a -> b, ra: Rand[a]): Rand[b] =
        rng ->
            let (a, rng2) = ra(rng);
            (f(a), rng2)

    // Exercise 6.1: 非負整数をランダム生成する関数 `nonNegativeInt` を実装せよ。

    pub def nonNegativeInt(): Rand[Int32] =
        ???

    // Exercise 6.2: 0以上1未満の浮動小数点数をランダム生成する関数 `double` を実装せよ。

    pub def double(): Rand[Float64] =
        ???

    pub def boolean(): Rand[Bool] =
        rng ->
            let (i, rng2) = int()(rng);
            (i `Int32.modulo` 2 == 0, rng2)

    // Exercise 6.3: 整数と浮動小数点数の組をランダム生成する関数 `intDouble` と `doubleInt` を実装せよ。
    // また、浮動小数点数の3つ組をランダム生成する関数 `double3` を実装せよ。

    pub def intDouble(): Rand[(Int32, Float64)] =
        ???

    pub def doubleInt(): Rand[(Float64, Int32)] =
        ???

    pub def double3(): Rand[(Float64, Float64, Float64)] =
        ???

    // Exercise 6.4: 引数で指定された要素数の整数リストをランダム生成する関数 `ints` を実装せよ。

    pub def ints(count: Int32): Rand[List[Int32]] =
        ???

    // Exercise 6.5: `map` を用いて `double` を実装せよ。

    pub def _double(): Rand[Float64] =
        ???

    // Exercise 6.6: 関数 `map2` を実装せよ。

    pub def map2(f: (a, b) -> c, ra: Rand[a], rb: Rand[b]): Rand[c] =
        ???

    pub def both(ra: Rand[a], rb: Rand[b]): Rand[(a, b)] =
        map2((a, b) -> (a, b), ra, rb)

    pub def randIntDouble(): Rand[(Int32, Float64)] =
        both(int(), double())

    pub def randDoubleInt(): Rand[(Float64, Int32)] =
        both(double(), int())

    // Exercise 6.7: 関数 `sequence` を実装せよ。

    pub def sequence(rs: List[Rand[a]]): Rand[List[a]] =
        ???

    pub def _ints(count: Int32): Rand[List[Int32]] =
        sequence(List.repeat(count, int()))

    // Exercise 6.8: 関数 `flatMap` を実装せよ。

    pub def flatMap(f: a -> Rand[b], ra: Rand[a]): Rand[b] =
        ???

    pub def nonNegativeLessThan(n: Int32): Rand[Int32] =
        flatMap(
            i ->
                let modulo = i `Int32.modulo` n;
                if (i + (n - 1) - modulo >= 0) unit(modulo) else nonNegativeLessThan(n),
            nonNegativeInt()
        )

    // Exercise 6.9: `flatMap` を用いて `map`, `map2` を実装せよ。

    pub def mapViaFlatMap(f: a -> b, ra: Rand[a]): Rand[b] =
        ???

    pub def map2ViaFlatMap(f: (a, b) -> c, ra: Rand[a], rb: Rand[b]): Rand[c] =
        ???
}
