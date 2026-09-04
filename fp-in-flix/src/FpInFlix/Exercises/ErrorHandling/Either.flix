pub mod FpInFlix.Exercises.ErrorHandling.Either {
    // NOTE: Flix標準ライブラリの `Result` に相当する
    // ref. https://api.flix.dev/Result.html
    pub enum Either[e, a] with Eq, ToString {
        case Left(e)
        case Right(a)
    }

    // Exercise 4.6: Optionに準じて `map`, `flatMap`, `orElse`, `map2` を実装せよ。

    pub def map(f: a -> b \ ef, et: Either[e, a]): Either[e, b] \ ef =
        ???

    pub def flatMap(f: a -> Either[e, b] \ ef, et: Either[e, a]): Either[e, b] \ ef =
        ???

    pub def orElse(other: Either[e, a], et: Either[e, a]): Either[e, a] =
        ???

    pub def map2(f: (a, b) -> c \ ef, et1: Either[e, a], et2: Either[e, b]): Either[e, c] \ ef =
        ???

    // Exercise 4.7: Optionに準じて `traverse`, `sequence` を実装せよ。

    pub def traverse(f: a -> Either[e, b] \ ef, xs: List[a]): Either[e, List[b]] \ ef =
        ???

    pub def sequence(xs: List[Either[e, a]]): Either[e, List[a]] =
        ???

    pub def mean(xs: Vector[Float64]): Either[String, Float64] =
        if (Vector.isEmpty(xs)) Left("mean of empty vector!")
        else Right(Vector.fold(xs) / Int32.toFloat64(Vector.length(xs)))
}
