// 関数型プログラミング(FP)では関数を取り回すことがよくあるため、
// 名前を付けること *なく* 関数を組み立てるシンタックスがあると便利だ
pub mod FpInFlix.Exercises.GettingStarted.AnonymousFunctions {
    use FpInFlix.Exercises.GettingStarted.MyProgram.{abs, factorial, formatResult}

    // 無名関数の例:
    pub def printAnonymousFunctions(): Unit \ IO =
        println(formatResult("absolute value", -42, abs));
        println(formatResult("factorial", 7, factorial));
        println(formatResult("increment", 7, (x: Int32) -> x + 1));
        println(formatResult("increment2", 7, (x) -> x + 1));
        println(formatResult("increment3", 7, x -> x + 1));
        println(formatResult("increment4", 7, x -> let r = x + 1; r))
}
