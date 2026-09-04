pub mod FpInFlix.Answers.ErrorHandling.Validated {
    use FpInFlix.Answers.ErrorHandling.Either

    // NOTE: Flix標準ライブラリの `Validation` に相当する
    // ref. https://api.flix.dev/Validation.html
    pub enum Validated[e, a] with Eq, ToString {
        case Valid(a)
        case Invalid(Nel[e])
    }

    pub def toEither(v: Validated[e, a]): Either[Nel[e], a] =
        match v {
            case Valid(a) => Either.Right(a)
            case Invalid(es) => Either.Left(es)
        }

    pub def fromEither(et: Either[Nel[e], a]): Validated[e, a] =
        match et {
            case Either.Right(a) => Valid(a)
            case Either.Left(es) => Invalid(es)
        }

    pub def map(f: a -> b \ ef, v: Validated[e, a]): Validated[e, b] \ ef =
        match v {
            case Valid(a) => Valid(f(a))
            case Invalid(es) => Invalid(es)
        }

    pub def map2(f: (a, b) -> c \ ef, v1: Validated[e, a], v2: Validated[e, b]): Validated[e, c] \ ef =
        match (v1, v2) {
            case (Valid(a), Valid(b)) => Valid(f(a, b))
            case (Invalid(es), Valid(_)) => Invalid(es)
            case (Valid(_), Invalid(es)) => Invalid(es)
            case (Invalid(es1), Invalid(es2)) => Invalid(es1 ++ es2)
        }

    pub def traverse(f: a -> Validated[e, b] \ ef, xs: List[a]): Validated[e, List[b]] \ ef =
        List.foldRight((x, acc) -> map2(List.cons, f(x), acc), Valid(Nil), xs)

    pub def sequence(xs: List[Validated[e, a]]): Validated[e, List[a]] =
        traverse(identity, xs)
}
