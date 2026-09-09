mod FpInFlix.Exercises.Laziness.TestLazyList {
    use Assert.{assertEq, assertFalse, assertTrue}
    // 解答例
    // use FpInFlix.Answers.Laziness.LazyList.{Cons, Empty, LazyList}
    use FpInFlix.Exercises.Laziness.LazyList.{Cons, Empty, LazyList}

    @Test
    def testToList(): Unit \ Assert =
        assertEq(expected = List#{1, 2, 3}, LazyList.toList(Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))));
        assertEq(expected = Nil, LazyList.toList((Empty: LazyList[Int32])))

    @Test
    def testTake(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2},
            LazyList.take(2, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.take(0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.take(5, (Empty: LazyList[Int32])) |> LazyList.toList)

    @Test
    def testDrop(): Unit \ Assert =
        assertEq(
            expected = List#{3},
            LazyList.drop(2, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(
            expected = List#{1, 2, 3},
            LazyList.drop(0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.drop(5, (Empty: LazyList[Int32])) |> LazyList.toList)

    @Test
    def testTakeWhile(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2},
            LazyList.takeWhile(x -> x < 3, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.takeWhile(x -> x < 0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.takeWhile(x -> x < 3, Empty) |> LazyList.toList
        )

    @Test
    def testForAll(): Unit \ Assert =
        assertTrue(LazyList.forAll(x -> x < 4, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))));
        assertFalse(LazyList.forAll(x -> x < 3, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))));
        assertTrue(LazyList.forAll(x -> x < 3, Empty))

    @Test
    def testTakeWhile_1(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2},
            LazyList.takeWhile_1(x -> x < 3, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.takeWhile_1(x -> x < 0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.takeWhile_1(x -> x < 3, Empty) |> LazyList.toList)

    @Test
    def testHeadOption(): Unit \ Assert =
        assertEq(expected = Some(1), LazyList.headOption(Cons(1, lazy Cons(2, lazy Empty))));
        assertEq(expected = None, LazyList.headOption((Empty: LazyList[Int32])))

    @Test
    def testMap(): Unit \ Assert =
        assertEq(
            expected = List#{2, 4, 6},
            LazyList.map(x -> x * 2, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.map(x -> x * 2, Empty) |> LazyList.toList)

    @Test
    def testFilter(): Unit \ Assert =
        assertEq(
            expected = List#{1, 3},
            LazyList.filter(x -> x `Int32.modulo` 2 != 0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.filter(x -> x `Int32.modulo` 2 != 0, Empty) |> LazyList.toList)

    @Test
    def testAppend(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2, 3, 4, 5},
            LazyList.append(Cons(1, lazy Cons(2, lazy Empty)),Cons(3, lazy Cons(4, lazy Cons(5, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(
            expected = List#{1, 2},
            LazyList.append(Cons(1, lazy Cons(2, lazy Empty)), Empty) |> LazyList.toList
        );
        assertEq(
            expected = List#{3, 4},
            LazyList.append(Empty, Cons(3, lazy Cons(4, lazy Empty))) |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.append((Empty: LazyList[Int32]), Empty) |> LazyList.toList)

    @Test
    def testFlatMap(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2, 3, 4},
            LazyList.flatMap(x -> Cons(x, lazy Cons(x + 1, lazy Empty)), Cons(1, lazy Cons(3, lazy Empty)))
                |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.flatMap(x -> Cons(x, lazy Cons(x + 1, lazy Empty)), Empty) |> LazyList.toList
        )

    @Test
    def testOnes(): Unit \ Assert =
        assertEq(expected = List#{1, 1, 1}, LazyList.ones() |> LazyList.take(3) |> LazyList.toList)

    @Test
    def testContinually(): Unit \ Assert =
        assertEq(expected = List#{5, 5, 5}, LazyList.continually(5) |> LazyList.take(3) |> LazyList.toList)

    @Test
    def testStartFrom(): Unit \ Assert =
        assertEq(expected = List#{3, 4, 5}, LazyList.startFrom(3) |> LazyList.take(3) |> LazyList.toList)

    @Test
    def testFibs(): Unit \ Assert =
        assertEq(
            expected = List#{0ii, 1ii, 1ii, 2ii, 3ii, 5ii},
            LazyList.fibs() |> LazyList.take(6) |> LazyList.toList
        )

    @Test
    def testUnfold(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2, 3, 4, 5},
            LazyList.unfold(x -> if (x <= 5) Some((x, x + 1)) else None, 1) |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.unfold(x -> if (x <= 0) Some((x, x + 1)) else None, 1) |> LazyList.toList
        )

    @Test
    def testFibsViaUnfold(): Unit \ Assert =
        assertEq(
            expected = List#{0ii, 1ii, 1ii, 2ii, 3ii, 5ii},
            LazyList.fibsViaUnfold() |> LazyList.take(6) |> LazyList.toList
        )

    @Test
    def testStartFromViaUnfold(): Unit \ Assert =
        assertEq(
            expected = List#{3, 4, 5},
            LazyList.startFromViaUnfold(3) |> LazyList.take(3) |> LazyList.toList
        )

    @Test
    def testContinuallyViaUnfold(): Unit \ Assert =
        assertEq(
            expected = List#{5, 5, 5},
            LazyList.continuallyViaUnfold(5) |> LazyList.take(3) |> LazyList.toList
        )

    @Test
    def testOnesViaUnfold(): Unit \ Assert =
        assertEq(expected = List#{1, 1, 1}, LazyList.onesViaUnfold() |> LazyList.take(3) |> LazyList.toList)

    @Test
    def testMapViaUnfold(): Unit \ Assert =
        assertEq(
            expected = List#{2, 4, 6},
            LazyList.mapViaUnfold(x -> x * 2, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.mapViaUnfold(x -> x * 2, Empty) |> LazyList.toList)

    @Test
    def testTakeViaUnfold(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2},
            LazyList.takeViaUnfold(2, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.takeViaUnfold(0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.takeViaUnfold(5, (Empty: LazyList[Int32])) |> LazyList.toList)

    @Test
    def testTakeWhileViaUnfold(): Unit \ Assert =
        assertEq(
            expected = List#{1, 2},
            LazyList.takeWhileViaUnfold(x -> x < 3, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.takeWhileViaUnfold(x -> x < 0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(expected = Nil, LazyList.takeWhileViaUnfold(x -> x < 3, Empty) |> LazyList.toList)

    @Test
    def testZipWith(): Unit \ Assert =
        assertEq(
            expected = List#{3, 5, 7},
            LazyList.zipWith(
                (x, y) -> x + y,
                Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))),
                Cons(2, lazy Cons(3, lazy Cons(4, lazy Empty)))
            ) |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.zipWith((x, y) -> x + y, Empty, Cons(2, lazy Cons(3, lazy Cons(4, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(
            expected = Nil,
            LazyList.zipWith((x, y) -> x + y, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))), Empty)
                |> LazyList.toList
        )

    @Test
    def testZipAll(): Unit \ Assert =
        assertEq(
            expected = List#{(Some(1), Some(2)), (Some(2), Some(3)), (Some(3), Some(4))},
            LazyList.zipAll(
                Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))),
                Cons(2, lazy Cons(3, lazy Cons(4, lazy Empty)))
            ) |> LazyList.toList
        );
        assertEq(
            expected = List#{(None, Some(2)), (None, Some(3)), (None, Some(4))},
            LazyList.zipAll((Empty: LazyList[Int32]), Cons(2, lazy Cons(3, lazy Cons(4, lazy Empty))))
                |> LazyList.toList
        );
        assertEq(
            expected = List#{(Some(1), None), (Some(2), None), (Some(3), None)},
            LazyList.zipAll(Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))), (Empty: LazyList[Int32]))
                |> LazyList.toList
        )

    @Test
    def testStartsWith(): Unit \ Assert =
        assertTrue(
            LazyList.startsWith(
                prefix = Cons(1, lazy Cons(2, lazy Empty)),
                Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))
            )
        );
        assertFalse(
            LazyList.startsWith(
                prefix = Cons(2, lazy Cons(3, lazy Empty)),
                Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))
            )
        );
        assertTrue(LazyList.startsWith(prefix = Empty, Cons(1, lazy Empty)));
        assertFalse(LazyList.startsWith(prefix = Cons(1, lazy Empty), Empty));
        assertTrue(LazyList.startsWith(prefix = (Empty: LazyList[Int32]), Empty))

    @Test
    def testTails(): Unit \ Assert =
        assertEq(
            expected = List#{List#{1, 2, 3}, List#{2, 3}, List#{3}, Nil},
            LazyList.tails(Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty))))
                |> LazyList.toList
                |> List.map(LazyList.toList)
        );
        assertEq(
            expected = List#{Nil},
            LazyList.tails((Empty: LazyList[Int32])) |> LazyList.toList |> List.map(LazyList.toList)
        )

    @Test
    def testHasSubsequence(): Unit \ Assert =
        assertTrue(
            LazyList.hasSubsequence(
                sub = Cons(2, lazy Cons(3, lazy Empty)),
                Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))
            )
        );
        assertFalse(
            LazyList.hasSubsequence(
                sub = Cons(3, lazy Cons(4, lazy Empty)),
                Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))
            )
        );
        assertTrue(LazyList.hasSubsequence(sub = Empty, Cons(1, lazy Empty)));
        assertFalse(LazyList.hasSubsequence(sub = Cons(1, lazy Empty), Empty));
        assertTrue(LazyList.hasSubsequence(sub = (Empty: LazyList[Int32]), Empty))

    @Test
    def testScanRight(): Unit \ Assert =
        assertEq(
            expected = List#{6, 5, 3, 0},
            LazyList.scanRight((+), 0, Cons(1, lazy Cons(2, lazy Cons(3, lazy Empty)))) |> LazyList.toList
        );
        assertEq(
            expected = List#{0},
            LazyList.scanRight((+), 0, Empty) |> LazyList.toList
        )
}
