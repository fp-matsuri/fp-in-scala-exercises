pub mod FpInFlix.Exercises.GettingStarted.TestFib {
    use FpInFlix.Exercises.GettingStarted.MyProgram.fib

    // `fib` に対するテストの実装
    pub def printFib(): Unit \ IO =
        println("Expected: 0, 1, 1, 2, 3, 5, 8");
        println("Actual: ${fib(0)}, ${fib(1)}, ${fib(2)}, ${fib(3)}, ${fib(4)}, ${fib(5)}, ${fib(6)}")
}
