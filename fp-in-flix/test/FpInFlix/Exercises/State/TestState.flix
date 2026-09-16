mod FpInFlix.Exercises.State.TestState {
    use Assert.assertEq
    // 解答例
    // use FpInFlix.Answers.State.State
    use FpInFlix.Exercises.State.State

    def stateA(): State[List[String], Option[String]] =
        State(s -> match s {
            case Nil => (None, Nil)
            case head :: tail => (Some(head), tail)
        })

    def stateB(): State[List[String], Int32] =
        State(s -> match s {
            case Nil => (0, Nil)
            case _ :: tail => (List.length(tail) + 1, tail)
        })

    @Test
    def testMap(): Unit \ Assert =
        List#{List#{"a", "bbb", "cc", ""}, Nil}
            |> List.forEach(l ->
                let (b, s) = State.map(length, stateA()) |> State.runState(l);
                assertEq(expected = l |> List.head |> length, b);
                assertEq(expected = List.drop(1, l), s)
            )

    @Test
    def testMap2(): Unit \ Assert =
        List#{List#{"a", "bbb", "cc", ""}, Nil}
            |> List.forEach(l ->
                let (c, s) = State.map2(printResult, stateA(), stateB()) |> State.runState(l);
                assertEq(expected = printResult(List.head(l), l |> List.drop(1) |> List.length), c);
                assertEq(expected = List.drop(2, l), s)
            )

    @Test
    def testFlatMap(): Unit \ Assert =
        List#{List#{"a", "bbb", "cc", ""}, Nil}
            |> List.forEach(l ->
                let (b, s) = State.flatMap(length >> State.unit, stateA()) |> State.runState(l);
                assertEq(expected = l |> List.head |> length, b);
                assertEq(expected = List.drop(1, l), s)
            )

    @Test
    def testUnit(): Unit \ Assert =
        let (a, s) = State.unit("a") |> State.runState(0);
        assertEq(expected = "a" , a);
        assertEq(expected = 0, s)

    @Test
    def testSequence(): Unit \ Assert =
        List#{List#{"a", "bbb", "cc", ""}, Nil}
            |> List.forEach(l ->
                let half = List.length(l) / 2;
                let listOfStates = List.repeat(half, stateA());
                let (firstHalfElements, restElements) = State.sequence(listOfStates) |> State.runState(l);
                let (first, rest) = List.splitAt(half, l);
                assertEq(expected = List.map(Some, first), firstHalfElements);
                assertEq(expected = rest, restElements)
            )

    def length(maybeHead: Option[String]): Int32 =
        maybeHead |> Option.getWithDefault("") |> String.length

    def printResult(maybeHead: Option[String], length: Int32): String =
        "The head element is '${maybeHead}', the length is ${length}"
}
