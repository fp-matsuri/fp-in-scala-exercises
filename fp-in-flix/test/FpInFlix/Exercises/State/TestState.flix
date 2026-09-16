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

    @Test
    def testSimulateMachine_machineThatIsOutOfCandy(): Unit \ Assert =
        foreach(
            locked <- List#{true, false};
            candies <- List#{0};
            coins <- List#{0, 5}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = List#{State.Input.Coin, State.Input.Turn};
            let (result, finalMachine) = State.simulateMachine(inputs) |> State.runState(machine);
            // 変化なし
            assertEq(expected = (coins, candies), result);
            assertEq(expected = machine#locked, finalMachine#locked);
            assertEq(expected = machine#candies, finalMachine#candies);
            assertEq(expected = machine#coins, finalMachine#coins)

    @Test
    def testSimulateMachine_insertingCoinIntoLockedMachine(): Unit \ Assert =
        foreach(
            locked <- List#{true};
            candies <- List#{1, 10};
            coins <- List#{0, 5}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = List#{State.Input.Coin};
            let (result, finalMachine) = State.simulateMachine(inputs) |> State.runState(machine);
            // コインが1枚増え、ロックが外れる
            assertEq(expected = (coins + 1, candies), result);
            assertEq(expected = false, finalMachine#locked);
            assertEq(expected = candies, finalMachine#candies);
            assertEq(expected = coins + 1, finalMachine#coins)

    @Test
    def testSimulateMachine_turningKnobOnLockedMachine(): Unit \ Assert =
        foreach(
            locked <- List#{true};
            candies <- List#{1, 10};
            coins <- List#{0, 5}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = List#{State.Input.Turn};
            let (result, finalMachine) = State.simulateMachine(inputs) |> State.runState(machine);
            // 変化なし
            assertEq(expected = (coins, candies), result);
            assertEq(expected = locked, finalMachine#locked);
            assertEq(expected = candies, finalMachine#candies);
            assertEq(expected = coins, finalMachine#coins)

    @Test
    def testSimulateMachine_insertingCoinIntoUnlockedMachine(): Unit \ Assert =
        foreach(
            locked <- List#{false};
            candies <- List#{1, 10};
            coins <- List#{0, 5}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = List#{State.Input.Coin};
            let (result, finalMachine) = State.simulateMachine(inputs) |> State.runState(machine);
            // 変化なし
            assertEq(expected = (coins, candies), result);
            assertEq(expected = locked, finalMachine#locked);
            assertEq(expected = candies, finalMachine#candies);
            assertEq(expected = coins, finalMachine#coins)

    @Test
    def testSimulateMachine_turningKnobOnUnlockedMachine(): Unit \ Assert =
        foreach(
            locked <- List#{false};
            candies <- List#{1, 10};
            coins <- List#{0, 5}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = List#{State.Input.Turn};
            let (result, finalMachine) = State.simulateMachine(inputs) |> State.runState(machine);
            // キャンディが1個減り、ロックが掛かる
            assertEq(expected = (coins, candies - 1), result);
            assertEq(expected = true, finalMachine#locked);
            assertEq(expected = candies - 1, finalMachine#candies);
            assertEq(expected = coins, finalMachine#coins)

    @Test
    def testSimulateMachine_spendSomeCoins(): Unit \ Assert =
        foreach(
            locked <- List#{true};
            candies <- List#{1, 10};
            coins <- List#{0, 5};
            myCoins <- List#{5, 10, 15}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = List#{State.Input.Coin, State.Input.Turn} |> List.repeat(myCoins) |> List.flatten;
            let (result, finalMachine) = State.simulateMachine(inputs) |> State.runState(machine);
            let spentCoins = Int32.min(candies, myCoins);
            // キャンディの残数が尽きるまでに使ったコインの分だけコインの枚数が増え、キャンディの個数が減る
            assertEq(expected = (coins + spentCoins, candies - spentCoins), result);
            assertEq(expected = true, finalMachine#locked);
            assertEq(expected = candies - spentCoins, finalMachine#candies);
            assertEq(expected = coins + spentCoins, finalMachine#coins)

    @Test
    def testSimulateMachine_emptyInputs(): Unit \ Assert =
        foreach(
            locked <- List#{true, false};
            candies <- List#{0, 1, 10};
            coins <- List#{0, 5}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = Nil;
            let (result, finalMachine) = State.simulateMachine(inputs) |> State.runState(machine);
            // 変化なし
            assertEq(expected = (coins, candies), result);
            assertEq(expected = locked, finalMachine#locked);
            assertEq(expected = candies, finalMachine#candies);
            assertEq(expected = coins, finalMachine#coins)

    def length(maybeHead: Option[String]): Int32 =
        maybeHead |> Option.getWithDefault("") |> String.length

    def printResult(maybeHead: Option[String], length: Int32): String =
        "The head element is '${maybeHead}', the length is ${length}"
}
