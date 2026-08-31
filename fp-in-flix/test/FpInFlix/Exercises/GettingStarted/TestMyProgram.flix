mod FpInFlix.Exercises.GettingStarted.TestMyProgram {
    use Assert.assertEq
    // 解答例
    // use FpInFlix.Answers.GettingStarted.{MyProgram => Sut}
    use FpInFlix.Exercises.GettingStarted.{MyProgram => Sut}

    @Test
    def testFactorial(): Unit \ Assert =
        assertEq(expected = 1, Sut.factorial(0));
        assertEq(expected = 1, Sut.factorial(1));
        assertEq(expected = 2, Sut.factorial(2));
        assertEq(expected = 6, Sut.factorial(3));
        assertEq(expected = 24, Sut.factorial(4));
        assertEq(expected = 120, Sut.factorial(5));
        assertEq(expected = 3628800, Sut.factorial(10))

    @Test
    def testFib(): Unit \ Assert =
        assertEq(expected = 0, Sut.fib(0));
        assertEq(expected = 1, Sut.fib(1));
        assertEq(expected = 1, Sut.fib(2));
        assertEq(expected = 2, Sut.fib(3));
        assertEq(expected = 3, Sut.fib(4));
        assertEq(expected = 5, Sut.fib(5));
        assertEq(expected = 55, Sut.fib(10))
}
