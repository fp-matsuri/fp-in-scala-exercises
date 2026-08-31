mod FpInFlix.Exercises.GettingStarted.TestPolymorphicFunctions {
    use Assert.{assertEq, assertFalse, assertTrue}
    // 解答例
    // use FpInFlix.Answers.GettingStarted.{PolymorphicFunctions => Sut}
    use FpInFlix.Exercises.GettingStarted.{PolymorphicFunctions => Sut}

    @Test
    def testIsSorted_empty(): Unit \ Assert =
        assertTrue(Sut.isSorted((>), (Vector.empty(): Vector[Int32])));
        assertTrue(Sut.isSorted((<), (Vector.empty(): Vector[Int32])))

    @Test
    def testIsSorted_singleElement(): Unit \ Assert =
        assertTrue(Sut.isSorted((>), Vector#{1}));
        assertTrue(Sut.isSorted((<), Vector#{1}))

    @Test
    def testIsSorted_multipleElements_ascending(): Unit \ Assert =
        assertTrue(Sut.isSorted((>), Vector#{1, 2, 3}));
        assertFalse(Sut.isSorted((<), Vector#{1, 2, 3}))

    @Test
    def testIsSorted_multipleElements_descending(): Unit \ Assert =
        assertFalse(Sut.isSorted((>), Vector#{3, 2, 1}));
        assertTrue(Sut.isSorted((<), Vector#{3, 2, 1}))

    @Test
    def testIsSorted_multipleElements_notSorted(): Unit \ Assert =
        assertFalse(Sut.isSorted((>), Vector#{1, 3, 2}));
        assertFalse(Sut.isSorted((<), Vector#{1, 3, 2}))

    @Test
    def testIsSorted_multipleElements_someDuplicates(): Unit \ Assert =
        assertTrue(Sut.isSorted((>), Vector#{1, 1, 2}));
        assertFalse(Sut.isSorted((<), Vector#{1, 1, 2}));
        assertFalse(Sut.isSorted((>), Vector#{2, 2, 1}));
        assertTrue(Sut.isSorted((<), Vector#{2, 2, 1}))

    @Test
    def testIsSorted_multipleElements_allDuplicates(): Unit \ Assert =
        assertTrue(Sut.isSorted((>), Vector#{1, 1, 1}));
        assertTrue(Sut.isSorted((<), Vector#{1, 1, 1}))

    @Test
    def testCurry(): Unit \ Assert =
        let mul = (*);
        let curriedMul = Sut.curry(mul);
        assertEq(expected = mul(2, 3), curriedMul(2)(3))

    @Test
    def testUncurry(): Unit \ Assert =
        let mul = (*);
        let uncurriedMul = Sut.uncurry(mul);
        assertEq(expected = mul(2)(3), uncurriedMul(2, 3))

    @Test
    def testCompose(): Unit \ Assert =
        let add = x -> x + 1;
        let mul = x -> x * 2;
        let addThenMul = Sut.compose(mul, add);
        assertEq(expected = mul(add(3)), addThenMul(3))
}
