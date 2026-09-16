pub mod FpInFlix.Answers.ErrorHandling.Option {
    use FpInFlix.Answers.ErrorHandling.Option.{None, Some}
    import java.lang.Math

    // ref. https://api.flix.dev/Option.html
    pub enum Option[a] with Eq, ToString {
        case None
        case Some(a)
    }

    // Exercise 4.1: 関数 `map` 、 `getOrElse` 、 `flatMap` 、 `orElse` 、 `filter` を実装せよ。
    // `getOrElse` は `Some` ならその中身の値を返し、 `None` なら引数のデフォルト値を返す。
    // `orElse` は `Some` ならそのまま返し、 `None` なら引数のOption値を返す。

    pub def map(f: a -> b \ ef, o: Option[a]): Option[b] \ ef =
        match o {
            case None => None
            case Some(a) => Some(f(a))
        }

    pub def getOrElse(default: a, o: Option[a]): a =
        match o {
            case None => default
            case Some(a) => a
        }

    pub def flatMap(f: a -> Option[b] \ ef, o: Option[a]): Option[b] \ ef =
        o |> map(f) |> getOrElse(None)

    pub def flatMap_1(f: a -> Option[b] \ ef, o: Option[a]): Option[b] \ ef =
        match o {
            case None => None
            case Some(a) => f(a)
        }

    pub def orElse(other: Option[a], o: Option[a]): Option[a] =
        o |> map(Some) |> getOrElse(other)

    pub def orElse_1(other: Option[a], o: Option[a]): Option[a] =
        match o {
            case None => other
            case _ => o
        }

    pub def filter(p: a -> Bool \ ef, o: Option[a]): Option[a] \ ef =
        match o {
            case None => None
            case Some(x) => if (p(x)) o else None
        }

    pub def filter_1(p: a -> Bool \ ef, o: Option[a]): Option[a] \ ef =
        flatMap(x -> if (p(x)) Some(x) else None, o)

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
        // NOTE: Javaメソッド呼び出しが純粋だと分かっている場合、 `unsafe IO` ブロックで囲むと純粋な式として扱われる
        // ref. https://doc.flix.dev/calling-methods.html#calling-java-methods-known-to-be-pure
        flatMap(m -> mean(Vector.map(x -> unsafe IO { Math.pow(x - m, 2.0) }, xs)), mean(xs))

    // Exercise 4.3: 2つのOption値がともに `Some` なら、2つの値に関数 `f` を適用する関数 `map2` を定義せよ。
    // どちらかが `None` なら結果も `None` になる。

    pub def map2(f: (a, b) -> c \ ef, o1: Option[a], o2: Option[b]): Option[c] \ ef =
        flatMap(x -> map(y -> f(x, y), o2), o1)

    // Exercise 4.4: OptionのリストをリストのOptionに変換する関数 `sequence` を定義せよ。

    pub def sequence(l: List[Option[a]]): Option[List[a]] =
        match l {
            case Nil => Some(Nil)
            case h :: t => flatMap(x -> map(xs -> List.cons(x, xs), sequence(t)), h)
        }

    pub def sequence_1(l: List[Option[a]]): Option[List[a]] =
        List.foldRight((x, acc) -> map2(List.cons, x, acc), Some(Nil), l)

    // Exercise 4.5: リストの要素に関数 `f` を適用した結果をリストのOptionに変換する関数 `traverse` を定義せよ。

    pub def traverse(f: a -> Option[b] \ ef, l: List[a]): Option[List[b]] \ ef =
        match l {
            case Nil => Some(Nil)
            case h :: t => map2(List.cons, f(h), traverse(f, t))
        }

    pub def traverse_1(f: a -> Option[b] \ ef, l: List[a]): Option[List[b]] \ ef =
        List.foldRight((x, acc) -> map2(List.cons, f(x), acc), Some(Nil), l)

    pub def sequenceViaTraverse(l: List[Option[a]]): Option[List[a]] =
        traverse(identity, l)
}
