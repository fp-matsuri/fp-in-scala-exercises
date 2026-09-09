mod FpInFlix.Exercises.DataStructures.TestList {
    use Assert.{assertEq, assertFalse, assertTrue}
    // 解答例
    // use FpInFlix.Answers.DataStructures.List.{Cons, List, Nil}
    use FpInFlix.Exercises.DataStructures.List.{Cons, List, Nil}

    @Test
    def testTail(): Unit \ Assert =
        assertEq(expected = Ok(Cons(2, Nil)), run {
            List.tail(Cons(1, Cons(2, Nil)))
        } with Abort.runWithResult);
        assertEq(expected = Ok(Nil), run {
            List.tail(Cons(1, Nil))
        } with Abort.runWithResult);
        assertEq(expected = Err(RichString.text("tail of empty list")), run {
            List.tail((Nil: List[Int32]))
        } with Abort.runWithResult)

    @Test
    def testSetHead(): Unit \ Assert =
        assertEq(expected = Ok(Cons(2, Cons(3, Nil))), run {
            List.setHead(Cons(1, Cons(3, Nil)), 2)
        } with Abort.runWithResult);
        assertEq(expected = Ok(Cons(2, Nil)), run {
            List.setHead(Cons(1, Nil), 2)
        } with Abort.runWithResult);
        assertEq(expected = Err(RichString.text("setHead on empty list")), run {
            List.setHead((Nil: List[Int32]), 2)
        } with Abort.runWithResult)

    @Test
    def testDrop(): Unit \ Assert =
        assertEq(expected = Cons(3, Nil), List.drop(2, Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = Nil, List.drop(3, Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = Nil, List.drop(2, (Nil: List[Int32])))

    @Test
    def testDropWhile(): Unit \ Assert =
        assertEq(expected = Cons(3, Nil), List.dropWhile(x -> x < 3, Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = Nil, List.dropWhile(x -> x < 4, Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = Nil, List.dropWhile(x -> x < 3, Nil))

    @Test
    def testInit(): Unit \ Assert =
        assertEq(expected = Ok(Cons(1, Nil)), run {
            List.init(Cons(1, Cons(2, Nil)))
        } with Abort.runWithResult);
        assertEq(expected = Ok(Nil), run {
            List.init(Cons(1, Nil))
        } with Abort.runWithResult);
        assertEq(expected = Err(RichString.text("init of empty list")), run {
            List.init((Nil: List[Int32]))
        } with Abort.runWithResult)

    @Test
    def testLength(): Unit \ Assert =
        assertEq(expected = 3, List.length(Cons(1, Cons(4, Cons(9, Nil)))));
        assertEq(expected = 0, List.length((Nil: List[Int32])))

    @Test
    def testFoldLeft(): Unit \ Assert =
        assertEq(expected = "123", List.foldLeft((acc, x) -> "${acc}${x}", "", Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = "", List.foldLeft((acc, x) -> "${acc}${x}", "", (Nil: List[Int32])))

    @Test
    def testSumViaFoldLeft(): Unit \ Assert =
        assertEq(expected = 6, List.sumViaFoldLeft(Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = 0, List.sumViaFoldLeft(Nil))

    @Test
    def testProductViaFoldLeft(): Unit \ Assert =
        assertEq(expected = 6.0, List.productViaFoldLeft(Cons(1.0, Cons(2.0, Cons(3.0, Nil)))));
        assertEq(expected = 1.0, List.productViaFoldLeft(Nil))

    @Test
    def testLengthViaFoldLeft(): Unit \ Assert =
        assertEq(expected = 3, List.lengthViaFoldLeft(Cons(1, Cons(4, Cons(9, Nil)))));
        assertEq(expected = 0, List.lengthViaFoldLeft((Nil: List[Int32])))

    @Test
    def testReverse(): Unit \ Assert =
        assertEq(expected = Cons(3, Cons(2, Cons(1, Nil))), List.reverse(Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = Nil, List.reverse((Nil: List[Int32])))

    @Test
    def testAppendViaFoldRight(): Unit \ Assert =
        assertEq(
            expected = Cons(1, Cons(2, Cons(3, Cons(4, Nil)))),
            List.appendViaFoldRight(Cons(1, Cons(2, Nil)), Cons(3, Cons(4, Nil)))
        );
        assertEq(expected = Cons(1, Cons(2, Nil)), List.appendViaFoldRight(Nil, Cons(1, Cons(2, Nil))));
        assertEq(expected = Cons(3, Cons(4, Nil)), List.appendViaFoldRight(Cons(3, Cons(4, Nil)), Nil));
        assertEq(expected = Nil, List.appendViaFoldRight((Nil: List[Int32]), Nil))

    @Test
    def testConcat(): Unit \ Assert =
        assertEq(
            expected = Cons(1, Cons(2, Cons(3, Cons(4, Nil)))),
            List.concat(Cons(Cons(1, Cons(2, Nil)), Cons(Cons(3, Cons(4, Nil)), Nil)))
        );
        assertEq(expected = Nil, List.concat((Nil: List[List[Int32]])))

    @Test
    def testIncrementEach(): Unit \ Assert =
        assertEq(expected = Cons(2, Cons(3, Cons(4, Nil))), List.incrementEach(Cons(1, Cons(2, Cons(3, Nil)))));
        assertEq(expected = Nil, List.incrementEach(Nil))

    @Test
    def testDoubleToString(): Unit \ Assert =
        assertEq(
            expected = Cons("1.0", Cons("2.0", Cons("3.0", Nil))),
            List.doubleToString(Cons(1.0, Cons(2.0, Cons(3.0, Nil))))
        );
        assertEq(expected = Nil, List.doubleToString(Nil))

    @Test
    def testMap(): Unit \ Assert =
        assertEq(
            expected = Cons(2, Cons(4, Cons(6, Nil))),
            List.map(x -> x * 2, Cons(1, Cons(2, Cons(3, Nil))))
        );
        assertEq(expected = Nil, List.map(x -> x * 2, Nil))

    @Test
    def testFilter(): Unit \ Assert =
        assertEq(
            expected = Cons(2, Cons(4, Nil)),
            List.filter(x -> x `Int32.modulo` 2 == 0, Cons(1, Cons(2, Cons(3, Cons(4, Nil)))))
        );
        assertEq(expected = Nil, List.filter(x -> x `Int32.modulo` 2 == 0, Nil))

    @Test
    def testFlatMap(): Unit \ Assert =
        assertEq(
            expected = Cons(1, Cons(1, Cons(2, Cons(2, Cons(3, Cons(3, Nil)))))),
            List.flatMap(x -> Cons(x, Cons(x, Nil)), Cons(1, Cons(2, Cons(3, Nil))))
        );
        assertEq(expected = Nil, List.flatMap(x -> Cons(x, Cons(x, Nil)), (Nil: List[Int32])))

    @Test
    def testFilterViaFlatMap(): Unit \ Assert =
        assertEq(
            expected = Cons(2, Cons(4, Nil)),
            List.filterViaFlatMap(x -> x `Int32.modulo` 2 == 0, Cons(1, Cons(2, Cons(3, Cons(4, Nil)))))
        );
        assertEq(expected = Nil, List.filterViaFlatMap(x -> x `Int32.modulo` 2 == 0, Nil))

    @Test
    def testAddPairwise(): Unit \ Assert =
        assertEq(
            expected = Cons(5, Cons(7, Cons(9, Nil))),
            List.addPairwise(Cons(1, Cons(2, Cons(3, Nil))), Cons(4, Cons(5, Cons(6, Cons(7, Nil)))))
            );
        assertEq(
            expected = Cons(6, Cons(8, Cons(10, Nil))),
            List.addPairwise(Cons(1, Cons(2, Cons(3, Cons(4, Nil)))), Cons(5, Cons(6, Cons(7, Nil))))
        );
        assertEq(expected = Nil, List.addPairwise(Cons(1, Cons(2, Cons(3, Nil))), Nil));
        assertEq(expected = Nil, List.addPairwise(Nil, Cons(4, Cons(5, Cons(6, Nil)))));
        assertEq(expected = Nil, List.addPairwise((Nil: List[Int32]), Nil))

    @Test
    def testZipWith(): Unit \ Assert =
        assertEq(
            expected = Cons(4, Cons(10, Cons(18, Nil))),
            List.zipWith((*), Cons(1, Cons(2, Cons(3, Nil))), Cons(4, Cons(5, Cons(6, Cons(7, Nil)))))
        );
        assertEq(
            expected = Cons(5, Cons(12, Cons(21, Nil))),
            List.zipWith((*), Cons(1, Cons(2, Cons(3, Cons(4, Nil)))), Cons(5, Cons(6, Cons(7, Nil))))
        );
        assertEq(expected = Nil, List.zipWith((*), Cons(1, Cons(2, Cons(3, Nil))), Nil));
        assertEq(expected = Nil, List.zipWith((*), Nil, Cons(4, Cons(5, Cons(6, Nil)))));
        assertEq(expected = Nil, List.zipWith((*), (Nil: List[Int32]), Nil))

    @Test
    def testHasSubsequence(): Unit \ Assert =
        assertTrue(
            List.hasSubsequence(sub = Cons(2, Cons(3, Nil)), Cons(1, Cons(2, Cons(3, Cons(4, Nil)))))
        );
        assertFalse(
            List.hasSubsequence(sub = Cons(2, Cons(4, Nil)), Cons(1, Cons(2, Cons(3, Cons(4, Nil)))))
        );
        assertTrue(
            List.hasSubsequence(sub = Nil, Cons(1, Cons(2, Cons(3, Cons(4, Nil)))))
        );
        assertFalse(
            List.hasSubsequence(sub = Cons(1, Nil), Nil)
        );
        assertTrue(
            List.hasSubsequence(sub = (Nil: List[Int32]), Nil)
        )
}
