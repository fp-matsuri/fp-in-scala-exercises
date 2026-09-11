pub mod FpInFlix.Exercises.GettingStarted.FormatAbsAndFactorial {
    use FpInFlix.Exercises.GettingStarted.MyProgram.{abs, factorial, formatResult}

    // 一般化した `formatResult` 関数を
    // `abs` と `factorial` の両方と一緒に利用することができる。
    pub def printAbsAndFactorial(): Unit \ IO =
        println(formatResult("absolute value", -42, abs));
        println(formatResult("factorial", 7, factorial))
}
