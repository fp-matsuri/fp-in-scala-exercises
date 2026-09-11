mod FpInFlix.Exercises.State.TestRng {
    use Assert.assertTrueWithMsg
    // 解答例
    // use FpInFlix.Answers.State.Rng
    use FpInFlix.Exercises.State.Rng

    @Test
    def testInt(): Unit \ Assert =
        assertRng(_ -> true, Rng(42i64), 1000, Rng.int())

    @Test
    def testUnit(): Unit \ Assert =
        assertRngUnit("unit", Rng(42i64), 1000);
        assertRngUnit(0, Rng(42i64), 1000);
        assertRngUnit(0.0, Rng(42i64), 1000)

    @Test
    def testMap(): Unit \ Assert =
        assertRng(Int32.fromString >> Option.nonEmpty, Rng(42i64), 1000, Rng.map(ToString.toString, Rng.int()))

    @Test
    def testNonNegativeInt(): Unit \ Assert =
        assertRng(n -> n >= 0, Rng(42i64), 1000, Rng.nonNegativeInt())

    @Test
    def testDouble(): Unit \ Assert =
        assertRng(isInInterval, Rng(42i64), 1000, Rng.double())

    @Test
    def testIntDouble(): Unit \ Assert =
        assertRng(match (_, d) -> isInInterval(d), Rng(42i64), 1000, Rng.intDouble())

    @Test
    def testDoubleInt(): Unit \ Assert =
        assertRng(match (d, _) -> isInInterval(d), Rng(42i64), 1000, Rng.doubleInt())

    @Test
    def testDouble3(): Unit \ Assert =
        assertRng(
            match (d1, d2, d3) ->
                isInInterval(d1) and isInInterval(d2) and isInInterval(d3)
                and d1 != d2 and d2 != d3 and d3 != d1,
            Rng(42i64), 1000, Rng.double3()
        )

    @Test
    def testInts(): Unit \ Assert =
        assertRng(xs -> List.length(xs) == xs |> List.distinct |> List.length, Rng(42i64), 1000, Rng.ints(10))

    @Test
    def test_double(): Unit \ Assert =
        assertRng(isInInterval, Rng(42i64), 1000, Rng._double())

    @Test
    def testMap2(): Unit \ Assert =
        assertRng(match (d1, d2) ->
            isInInterval(d1) and isInInterval(d2) and d1 != d2,
            Rng(42i64), 1000,
            Rng.map2((d1, d2) -> (d1, d2), Rng.double(), Rng.double())
        )

    @Test
    def testSequence(): Unit \ Assert =
        assertRng(
            xs -> List.length(xs) == xs |> List.distinct |> List.length,
            Rng(42i64), 1000,
            Rng.sequence(List.repeat(10, Rng.int()))
        )

    @Test
    def testFlatMap(): Unit \ Assert =
        let limit = 100;
        assertRngNonNegativeLessThan(limit, Rng(42i64), 1000, Rng.nonNegativeLessThan(limit))

    @Test
    def testMapViaFlatMap(): Unit \ Assert =
        assertRng(
            Int32.fromString >> Option.nonEmpty,
            Rng(42i64), 1000,
            Rng.mapViaFlatMap(ToString.toString, Rng.int())
        )

    @Test
    def testMap2ViaFlatMap(): Unit \ Assert =
        assertRng(
            match (d1, d2) ->
                isInInterval(d1) and isInInterval(d2) and d1 != d2,
            Rng(42i64), 1000,
            Rng.map2ViaFlatMap((d1, d2) -> (d1, d2), Rng.double(), Rng.double())
        )

    def assertRng(isCorrect: a -> Bool, init: Rng, count: Int32, ra: Rng.Rand[a]): Unit \ Assert with Eq[a], ToString[a] =
        let vals = randomValues(init, count, ra);
        let invalidVals = List.filter(x -> not isCorrect(x), vals);
        assertTrueWithMsg(List.isEmpty(invalidVals), "Invalid value(s) generated: ${invalidVals}.");
        assertTrueWithMsg(
            List.zip(vals, List.drop(1, vals)) |> List.forAll(match (x, y) -> x != y),
            "Two identical values in a row generated."
        )

    def assertRngUnit(constant: a, init: Rng, count: Int32): Unit \ Assert with Eq[a], ToString[a] =
        let vals = randomValues(init, count, Rng.unit(constant));
        assertTrueWithMsg(List.forAll(x -> x == constant, vals), "Not all values are equal to ${constant}.")

    def assertRngNonNegativeLessThan(limit: Int32, init: Rng, count: Int32, ra: Rng.Rand[Int32]): Unit \ Assert =
        let vals = randomValues(init, count, ra);
        assertTrueWithMsg(
            List.forAll(x -> x >= 0 and x < limit, vals),
            "Not all values are in the interval [0, ${limit})."
        )

    def randomValues(init: Rng, count: Int32, ra: Rng.Rand[a]): List[a] =
        List.unfold(match (r1, c) ->
            if (c <= 0) None
            else
                let (n, r2) = ra(r1);
                Some((n, (r2, c - 1))),
            (init, count)
        )

    def isInInterval(d: Float64): Bool =
        d >= 0.0 and d < 1.0
}
