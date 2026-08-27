pub mod FpInFlix.Exercises.GettingStarted.MyProgram {
    pub def factorial(n: Int32): Int32 =
        @Tailrec
        def go(x, acc) =
            if (x <= 0) acc
            else go(x - 1, x * acc);
        go(n, 1)
}
