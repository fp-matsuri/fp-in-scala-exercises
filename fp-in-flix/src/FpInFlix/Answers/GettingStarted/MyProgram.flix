// コメント!
/* 別のコメント! */
/// ドキュメンテーションコメント!
pub mod FpInFlix.Answers.GettingStarted.MyProgram {
    pub def abs(x: Int32): Int32 =
        if (x < 0) -x
        else x

    def formatAbs(x: Int32): String =
        "The absolute value of ${x} is ${abs(x)}"

    // NOTE: Flixでは関数の持つエフェクトが `\ IO` のように戻り型の直後に示される(省略されているときはエフェクトがなく純粋)。
    // ref. https://doc.flix.dev/effect-system.html
    pub def printAbs(): Unit \ IO =
        println(formatAbs(-42))

    // ローカルな末尾再帰関数を用いた階乗の定義
    pub def factorial(n: Int32): Int32 =
        // NOTE: `@Tailrec` アノテーションは関数が末尾再帰形でない場合にコンパイルエラーにする
        // ref. https://doc.flix.dev/tail-recursion.html
        @Tailrec
        // NOTE: トップレベル関数では型注釈が必須だが、ローカル関数では省略できる
        def go(x, acc) =
            if (x <= 0) acc
            else go(x - 1, x * acc);
        go(n, 1)

    // 今度は `foreach` ループによる `factorial` の別の実装
    pub def factorial2(n: Int32): Int32 =
        // NOTE: `region` ブロックの中で局所的に `Ref` による可変参照を利用している
        // ref. https://doc.flix.dev/references.html
        region rc {
            let acc = Ref.fresh(rc, 1);
            foreach (i <- Range.Range(1, n + 1))
                Ref.transform(x -> x * i, acc);
            Ref.get(acc)
        }

    // Exercise 2.1: n番目のフィボナッチ数を計算する関数 `fib` を定義せよ。

    // 0と1が数列の最初の2つの数なので、アキュムレータ(累積変数)をそこから始める。
    // 繰り返しのたびに2つの数を加えて次の数とする。
    pub def fib(n: Int32): Int32 =
        @Tailrec
        def go(x, current, next) =
            if (x <= 0) current
            else go(x - 1, next, current + next);
        go(n, 0, 1)

    // この定義と `formatAbs` はとてもよく似ている。
    pub def formatFactorial(n: Int32): String =
        "The factorial of ${n} is ${factorial(n)}."

    // `formatAbs` と `formatFactorial` が
    // パラメータとして _関数_ を受け付けるように一般化できる。
    pub def formatResult(name: String, n: Int32, f: Int32 -> Int32): String =
        "The ${name} of ${n} is ${f(n)}."
}
