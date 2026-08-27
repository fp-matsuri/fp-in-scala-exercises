// A comment!
/* Another comment! */
/// A documentation comment!
pub mod FpInFlix.Answers.GettingStarted.MyProgram {
    pub def abs(x: Int32): Int32 =
        if (x < 0) -x
        else x

    def formatAbs(x: Int32): String =
        "The absolute value of ${x} is ${abs(x)}"

    pub def printAbs(): Unit \ IO =
        println(formatAbs(-42))

    // A definition of factorial, using a local, tail recursive function
    pub def factorial(n: Int32): Int32 =
        @Tailrec
        def go(x, acc) =
            if (x <= 0) acc
            else go(x - 1, x * acc);
        go(n, 1)

    // Another implementation of `factorial`, this time with a `foreach` loop
    pub def factorial2(n: Int32): Int32 =
        region rc {
            let acc = Ref.fresh(rc, 1);
            foreach (i <- Range.Range(1, n + 1))
                Ref.transform(x -> x * i, acc);
            Ref.get(acc)
        }

    // Exercise 2.1: Write a function to compute the nth fibonacci number

    pub def fib(n: Int32): Int32 =
        @Tailrec
        def go(x, current, next) =
            if (x <= 0) current
            else go(x - 1, next, current + next);
        go(n, 0, 1)

    // This definition and `formatAbs` are very similar..
    pub def formatFactorial(n: Int32): String =
        "The factorial of ${n} is ${factorial(n)}."

    // We can generalize `formatAbs` and `formatFactorial` to
    // accept a _function_ as a parameter
    pub def formatResult(name: String, n: Int32, f: Int32 -> Int32): String =
        "The ${name} of ${n} is ${f(n)}."
}
