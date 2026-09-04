mod FpInFlix.Exercises.DataStructures.TestTree {
    use Assert.assertEq
    // 解答例
    // use FpInFlix.Answers.DataStructures.Tree.{Branch, Leaf, Tree}
    use FpInFlix.Exercises.DataStructures.Tree.{Branch, Leaf, Tree}

    @Test
    def testSize(): Unit \ Assert =
        assertEq(expected = 1, Tree.size(Leaf(1)));
        assertEq(expected = 3, Tree.size(Branch(Leaf(1), Leaf(2))));
        assertEq(expected = 5, Tree.size(Branch(Branch(Leaf(1), Leaf(2)), Leaf(3))));
        assertEq(expected = 7, Tree.size(Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4)))))

    @Test
    def testFirstPositive(): Unit \ Assert =
        assertEq(expected = 1, Tree.firstPositive(Leaf(1)));
        assertEq(expected = 2, Tree.firstPositive(Branch(Leaf(-1), Leaf(2))));
        assertEq(expected = 3, Tree.firstPositive(Branch(Branch(Leaf(-1), Leaf(-2)), Leaf(3))));
        assertEq(
            expected = 4,
            Tree.firstPositive(Branch(Branch(Leaf(-1), Leaf(-2)), Branch(Leaf(-3), Leaf(4))))
        )

    @Test
    def testMaximum(): Unit \ Assert =
        assertEq(expected = 1, Tree.maximum(Leaf(1)));
        assertEq(expected = 2, Tree.maximum(Branch(Leaf(1), Leaf(2))));
        assertEq(expected = 3, Tree.maximum(Branch(Branch(Leaf(1), Leaf(2)), Leaf(3))));
        assertEq(expected = 4, Tree.maximum(Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4)))))

    @Test
    def testDepth(): Unit \ Assert =
        assertEq(expected = 0, Tree.depth(Leaf(1)));
        assertEq(expected = 1, Tree.depth(Branch(Leaf(1), Leaf(2))));
        assertEq(expected = 2, Tree.depth(Branch(Branch(Leaf(1), Leaf(2)), Leaf(3))));
        assertEq(expected = 2, Tree.depth(Branch(Leaf(1), Branch(Leaf(2), Leaf(3)))));
        assertEq(expected = 2, Tree.depth(Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4)))));
        assertEq(expected = 3, Tree.depth(Branch(Branch(Leaf(1), Branch(Leaf(2), Leaf(3))), Leaf(4))))

    @Test
    def testMap(): Unit \ Assert =
        assertEq(expected = Leaf("1"), Tree.map(ToString.toString, Leaf(1)));
        assertEq(
            expected = Branch(Leaf("1"), Leaf("2")),
            Tree.map(ToString.toString, Branch(Leaf(1), Leaf(2)))
        );
        assertEq(
            expected = Branch(Branch(Leaf("1"), Leaf("2")), Leaf("3")),
            Tree.map(ToString.toString, Branch(Branch(Leaf(1), Leaf(2)), Leaf(3)))
        );
        assertEq(
            expected = Branch(Branch(Leaf("1"), Leaf("2")), Branch(Leaf("3"), Leaf("4"))),
            Tree.map(ToString.toString, Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4))))
        )

    @Test
    def testFold(): Unit \ Assert =
        assertEq(
            expected = "1",
            Tree.fold(ToString.toString, String.concat, Leaf(1))
        );
        assertEq(
            expected = "12",
            Tree.fold(ToString.toString, String.concat, Branch(Leaf(1), Leaf(2)))
        );
        assertEq(
            expected = "123",
            Tree.fold(ToString.toString, String.concat, Branch(Branch(Leaf(1), Leaf(2)), Leaf(3)))
        )

    @Test
    def testSizeViaFold(): Unit \ Assert =
        assertEq(expected = 1, Tree.sizeViaFold(Leaf(1)));
        assertEq(expected = 3, Tree.sizeViaFold(Branch(Leaf(1), Leaf(2))));
        assertEq(expected = 5, Tree.sizeViaFold(Branch(Branch(Leaf(1), Leaf(2)), Leaf(3))));
        assertEq(expected = 7, Tree.sizeViaFold(Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4)))))

    @Test
    def testDepthViaFold(): Unit \ Assert =
        assertEq(expected = 0, Tree.depthViaFold(Leaf(1)));
        assertEq(expected = 1, Tree.depthViaFold(Branch(Leaf(1), Leaf(2))));
        assertEq(expected = 2, Tree.depthViaFold(Branch(Branch(Leaf(1), Leaf(2)), Leaf(3))));
        assertEq(expected = 2, Tree.depthViaFold(Branch(Leaf(1), Branch(Leaf(2), Leaf(3)))));
        assertEq(
            expected = 2,
            Tree.depthViaFold(Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4))))
        );
        assertEq(expected = 3, Tree.depthViaFold(Branch(Branch(Leaf(1), Branch(Leaf(2), Leaf(3))), Leaf(4))))

    @Test
    def testMapViaFold(): Unit \ Assert =
        assertEq(expected = Leaf("1"), Tree.mapViaFold(ToString.toString, Leaf(1)));
        assertEq(
            expected = Branch(Leaf("1"), Leaf("2")),
            Tree.mapViaFold(ToString.toString, Branch(Leaf(1), Leaf(2)))
        );
        assertEq(
            expected = Branch(Branch(Leaf("1"), Leaf("2")), Leaf("3")),
            Tree.mapViaFold(ToString.toString, Branch(Branch(Leaf(1), Leaf(2)), Leaf(3)))
        );
        assertEq(
            expected = Branch(Branch(Leaf("1"), Leaf("2")), Branch(Leaf("3"), Leaf("4"))),
            Tree.mapViaFold(ToString.toString, Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4))))
        )

    @Test
    def testMaximumViaFold(): Unit \ Assert =
        assertEq(expected = 1, Tree.maximumViaFold(Leaf(1)));
        assertEq(expected = 2, Tree.maximumViaFold(Branch(Leaf(1), Leaf(2))));
        assertEq(expected = 3, Tree.maximumViaFold(Branch(Branch(Leaf(1), Leaf(2)), Leaf(3))));
        assertEq(
            expected = 4,
            Tree.maximumViaFold(Branch(Branch(Leaf(1), Leaf(2)), Branch(Leaf(3), Leaf(4))))
        )
}
