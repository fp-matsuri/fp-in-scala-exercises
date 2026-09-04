pub mod FpInFlix.Exercises.ErrorHandling.Option {
    use FpInFlix.Exercises.ErrorHandling.Option.{None, Some}
    import java.lang.Math

    // ref. https://api.flix.dev/Option.html
    pub enum Option[a] with Eq, ToString {
        case None
        case Some(a)
    }

    mod FlixOption {
        use FpInFlix.Exercises.ErrorHandling.{Option => MyOption}

        /// Flix標準ライブラリの `Option` を独自定義の `Option` に変換する。
        pub def toOption(o: Option[a]): MyOption[a] =
            Option.foldLeft((_, x) -> MyOption.Some(x), MyOption.None, o)
    }

    // Exercise 4.1: 関数 `map` 、 `getOrElse` 、 `flatMap` 、 `orElse` 、 `filter` を実装せよ。
    // `getOrElse` は `Some` ならその中身の値を返し、 `None` なら引数のデフォルト値を返す。
    // `orElse` は `Some` ならそのまま返し、 `None` なら引数のOption値を返す。

    pub def map(f: a -> b \ ef, o: Option[a]): Option[b] \ ef =
        ???

    pub def getOrElse(default: a, o: Option[a]): a =
        ???

    pub def flatMap(f: a -> Option[b] \ ef, o: Option[a]): Option[b] \ ef =
        ???

    pub def orElse(other: Option[a], o: Option[a]): Option[a] =
        ???

    pub def filter(p: a -> Bool \ ef, o: Option[a]): Option[a] \ ef =
        ???

    pub def failingFn(): Int32 \ Abort =
        let y = Abort.abort(RichString.text("fail!"));
        (run {
            let x = 42 + 5;
            x + y
        } with Abort.runWithResult)
            |> Result.getWithDefault(43)

    pub def failingFn2(): Int32 =
        (run {
            let x = 42 + 5;
            x + Abort.abort(RichString.text("fail!"))
        } with Abort.runWithResult)
            |> Result.getWithDefault(43)

    pub def mean(xs: Vector[Float64]): Option[Float64] =
        if (Vector.isEmpty(xs)) None
        else Some(Vector.fold(xs) / Int32.toFloat64(Vector.length(xs)))

    // Exercise 4.2: 分散(平均からの偏差の2乗の平均)を計算する関数 `variance` を定義せよ。

    pub def variance(xs: Vector[Float64]): Option[Float64] =
        ???

    // Exercise 4.3: 2つのOption値がともに `Some` なら、2つの値に関数 `f` を適用する関数 `map2` を定義せよ。
    // どちらかが `None` なら結果も `None` になる。

    pub def map2(f: (a, b) -> c \ ef, o1: Option[a], o2: Option[b]): Option[c] \ ef =
        ???

    // Exercise 4.4: OptionのリストをリストのOptionに変換する関数 `sequence` を定義せよ。

    pub def sequence(l: List[Option[a]]): Option[List[a]] =
        ???

    // Exercise 4.5: リストの要素に関数 `f` を適用した結果をリストのOptionに変換する関数 `traverse` を定義せよ。

    pub def traverse(f: a -> Option[b] \ ef, l: List[a]): Option[List[b]] \ ef =
        ???
}
