mod FpInFlix.Exercises.ErrorHandling.TestOption {
    use Assert.assertEq
    // 解答例
    // use FpInFlix.Answers.ErrorHandling.Option.{None, Option, Some}
    use FpInFlix.Exercises.ErrorHandling.Option.{None, Option, Some}

    mod FlixOption {
        // 解答例
        // use FpInFlix.Answers.ErrorHandling.{Option => MyOption}
        use FpInFlix.Exercises.ErrorHandling.{Option => MyOption}

        /// Flix標準ライブラリの `Option` を独自定義の `Option` に変換する。
        pub def toOption(o: Option[a]): MyOption[a] =
            Option.foldLeft((_, x) -> MyOption.Some(x), MyOption.None, o)
    }

    @Test
    def testMap(): Unit \ Assert =
        assertEq(expected = Some("42"), Option.map(ToString.toString, Some(42)));
        assertEq(expected = None, Option.map(ToString.toString, (None: Option[Int32])))

    @Test
    def testGetOrElse(): Unit \ Assert =
        assertEq(expected = 42, Option.getOrElse(1, Some(42)));
        assertEq(expected = 1, Option.getOrElse(1, None))

    @Test
    def testFlatMap(): Unit \ Assert =
        assertEq(expected = Some("42"), Option.flatMap(ToString.toString >> Some, Some(42)));
        assertEq(expected = None, Option.flatMap(ToString.toString >> Some, (None: Option[Int32])))

    @Test
    def testOrElse(): Unit \ Assert =
        assertEq(expected = Some(42), Option.orElse(Some(1), Some(42)));
        assertEq(expected = Some(42), Option.orElse(None, Some(42)));
        assertEq(expected = Some(1), Option.orElse(Some(1), None));
        assertEq(expected = None, Option.orElse((None: Option[Int32]), None))

    @Test
    def testFilter(): Unit \ Assert =
        assertEq(expected = Some(42), Option.filter(x -> x == 42, Some(42)));
        assertEq(expected = None, Option.filter(x -> x == 42, Some(1)));
        assertEq(expected = None, Option.filter(x -> x == 42, (None: Option[Int32])))

    @Test
    def testMean(): Unit \ Assert =
        assertEq(expected = Some(2.5), Option.mean(Vector#{1.5, 2.0, 4.0}));
        assertEq(expected = None, Option.mean(Vector.empty()))

    @Test
    def testVariance(): Unit \ Assert =
        assertEq(expected = Some(1.1666666666666667), Option.variance(Vector#{1.5, 2.0, 4.0}));
        assertEq(expected = None, Option.variance(Vector.empty()))

    @Test
    def testMap2(): Unit \ Assert =
        assertEq(expected = Some(3), Option.map2((+), Some(1), Some(2)));
        assertEq(expected = None, Option.map2((+), None, Some(2)));
        assertEq(expected = None, Option.map2((+), Some(1), None));
        assertEq(expected = None, Option.map2((+), (None: Option[Int32]), None))

    @Test
    def testSequence(): Unit \ Assert =
        assertEq(expected = Some(List#{1, 2, 3}), Option.sequence(List#{Some(1), Some(2), Some(3)}));
        assertEq(expected = None, Option.sequence(List#{Some(1), None, Some(3)}));
        assertEq(expected = Some(Nil), Option.sequence((Nil: List[Option[Int32]])))

    @Test
    def testTraverse(): Unit \ Assert =
        assertEq(
            expected = Some(List#{1, 2, 3}),
            Option.traverse(Int32.fromString >> FlixOption.toOption, List#{"1", "2", "3"})
        );
        assertEq(
            expected = None,
            Option.traverse(Int32.fromString >> FlixOption.toOption, List#{"1", "a", "3"})
        );
        assertEq(
            expected = Some(Nil),
            Option.traverse(Int32.fromString >> FlixOption.toOption, Nil)
        )
}
