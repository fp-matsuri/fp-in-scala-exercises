mod FpInFlix.Exercises.State.TestCandy {
    use Assert.assertEq
    // 解答例
    // use FpInFlix.Answers.State.Candy
    // use FpInFlix.Answers.State.State
    use FpInFlix.Exercises.State.Candy
    use FpInFlix.Exercises.State.State

    @Test
    def testSimulateMachine_machineThatIsOutOfCandy(): Unit \ Assert =
        foreach(
            locked <- List#{true, false};
            candies <- List#{0};
            coins <- List#{0, 5}
        )
            let machine = {locked = locked, candies = candies, coins = coins};
            let inputs = List#{Candy.Input.Coin, Candy.Input.Turn};
            let (result, finalMachine) = Candy.simulateMachine(inputs) |> State.runState(machine);
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
            let inputs = List#{Candy.Input.Coin};
            let (result, finalMachine) = Candy.simulateMachine(inputs) |> State.runState(machine);
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
            let inputs = List#{Candy.Input.Turn};
            let (result, finalMachine) = Candy.simulateMachine(inputs) |> State.runState(machine);
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
            let inputs = List#{Candy.Input.Coin};
            let (result, finalMachine) = Candy.simulateMachine(inputs) |> State.runState(machine);
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
            let inputs = List#{Candy.Input.Turn};
            let (result, finalMachine) = Candy.simulateMachine(inputs) |> State.runState(machine);
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
            let inputs = List#{Candy.Input.Coin, Candy.Input.Turn} |> List.repeat(myCoins) |> List.flatten;
            let (result, finalMachine) = Candy.simulateMachine(inputs) |> State.runState(machine);
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
            let (result, finalMachine) = Candy.simulateMachine(inputs) |> State.runState(machine);
            // 変化なし
            assertEq(expected = (coins, candies), result);
            assertEq(expected = locked, finalMachine#locked);
            assertEq(expected = candies, finalMachine#candies);
            assertEq(expected = coins, finalMachine#coins)
}
