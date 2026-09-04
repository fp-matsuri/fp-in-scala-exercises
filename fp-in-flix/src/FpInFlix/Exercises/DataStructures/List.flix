pub mod FpInFlix.Exercises.DataStructures.List {
    use FpInFlix.Exercises.DataStructures.List.{Cons, Nil}

    /// 型 `a` でパラメータ化された `List` データ型。
    /// ref. https://api.flix.dev/List.html
    pub enum List[a] with Eq, ToString {
        /// 空リストを表す `List` のデータコンストラクタ。
        case Nil
        /// 非空リストを表す別のデータコンストラクタ。
        /// 第2引数は別の `List[a]` (`Nil` もしくは別の `Cons`)であることに注目。
        case Cons(a, List[a])
    }

    mod FlixList {
        use FpInFlix.Exercises.DataStructures.{List => MyList}

        /// Flix標準ライブラリの `List` を独自定義の `List` に変換する。
        pub def toList(xs: List[a]): MyList[a] =
            List.foldRight(MyList.Cons, MyList.Nil, xs)
    }

    pub def sum(ints: List[Int32]): Int32 =
        match ints {  // 整数リストを足し上げるためにパターンマッチングを使う関数
            case Nil => 0  // 空の整数リストの和は0
            case Cons(x, xs) => x + sum(xs)  // `x` で始まるリストの和は `x` に残りのリストの和を加えたもの
        }

    pub def product(doubles: List[Float64]): Float64 =
        match doubles {
            case Nil => 1.0
            case Cons(0.0, _) => 0.0
            case Cons(x, xs) => x * product(xs)
        }

    // Exercise 3.1: 以下の式 `result()` の評価結果は何になるか? (推測してからREPLで確認してみよう)

    pub def result(): Int32 =
        match Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil))))) {
            case Cons(x, Cons(2, Cons(4, _))) => x
            case Nil => 42
            case Cons(x, Cons(y, Cons(3, Cons(4, _)))) => x + y
            case Cons(h, t) => h + sum(t)
            // NOTE: Flixでは到達不可能なパターン(分岐)があるとコンパイルエラーになる
            // case _ => 101
        }

    pub def append(a1: List[a], a2: List[a]): List[a] =
        match a1 {
            case Nil => a2
            case Cons(h, t) => Cons(h, append(t, a2))
        }

    // NOTE: Flixでは、高階関数の関数引数の任意のエフェクト(ここではエフェクト変数 `ef`)がその高階関数のエフェクトに伝播するようにすることができる。
    // これはエフェクト多相(effect polymorphism)と呼ばれ、エフェクトなし(純粋)に固定されないことで高階関数の再利用性が高まる。
    // ref. https://doc.flix.dev/effect-polymorphism.html
    pub def foldRight(f: (a, b) -> b \ ef, acc: b, l: List[a]): b \ ef =
        match l {
            case Nil => acc
            case Cons(x, xs) => f(x, foldRight(f, acc, xs))
        }

    pub def sumViaFoldRight(ns: List[Int32]): Int32 =
        // NOTE: Flixでは記号演算子(記号のみで構成された関数名)を丸括弧で括って参照できる
        foldRight((+), 0, ns)

    pub def productViaFoldRight(ns: List[Float64]): Float64 =
        foldRight((*), 1.0, ns)

    // Exercise 3.2: 先頭要素以外のリストを返す関数 `tail` を定義せよ。

    pub def tail(l: List[a]): List[a] \ Abort =
        ???

    // Exercise 3.3: リストの先頭要素を別の値に置き換える関数 `setHead` を定義せよ。

    pub def setHead(l: List[a], h: a): List[a] \ Abort =
        ???

    // Exercise 3.4: リストの先頭から `n` 個の要素を取り除く関数 `drop` を定義せよ。

    pub def drop(n: Int32, l: List[a]): List[a] =
        ???

    // Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数 `dropWhile` を定義せよ。

    pub def dropWhile(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        ???

    // Exercise 3.6: 末尾要素以外のリストを返す関数 `init` を定義せよ。

    pub def init(l: List[a]): List[a] \ Abort =
        ???

    // Exercise 3.7: `foldRight` によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか?

    // Exercise 3.8: `foldRight` の引数 `acc` に `Nil` 、 `f` に `Cons` を与えるとどのような結果が得られるか? (推測してからREPLで確認してみよう)

    // Exercise 3.9: リストの要素数を数える関数 `length` を定義せよ。

    pub def length(l: List[a]): Int32 =
        ???

    // Exercise 3.10: リストを左端から畳み込む `foldLeft` 関数を末尾再帰関数として定義せよ。

    pub def foldLeft(f: (b, a) -> b \ ef, acc: b, l: List[a]): b \ ef =
        ???

    // Exercise 3.11: `foldLeft` を用いて `sum`, `product`, `length` を定義せよ。

    pub def sumViaFoldLeft(l: List[Int32]): Int32 =
        ???

    pub def productViaFoldLeft(l: List[Float64]): Float64 =
        ???

    pub def lengthViaFoldLeft(l: List[a]): Int32 =
        ???

    // Exercise 3.12: `foldLeft` を用いてリストを逆順にする関数 `reverse` を定義せよ。

    pub def reverse(l: List[a]): List[a] =
        ???

    // Exercise 3.13: `foldLeft` を用いて `foldRight` を定義することは可能か? 可能であれば定義せよ。

    // Exercise 3.14: `foldRight` を用いて `append` を定義せよ。

    pub def appendViaFoldRight(l1: List[a], l2: List[a]): List[a] =
        ???

    // Exercise 3.15: `foldRight` を用いてリストのリストを1つのリストに連結する関数 `concat` を定義せよ。

    pub def concat(ls: List[List[a]]): List[a] =
        ???

    // Exercise 3.16: `foldRight` を用いてリストの各要素に1を加える関数 `incrementEach` を定義せよ。

    pub def incrementEach(l: List[Int32]): List[Int32] =
        ???

    // Exercise 3.17: `foldRight` を用いてリストの各要素の数値を文字列に変換する関数 `doubleToString` を定義せよ。

    pub def doubleToString(l: List[Float64]): List[String] =
        ???

    // Exercise 3.18: `doubleToString` を一般化して、リストの各要素に関数 `f` を適用する関数 `map` を定義せよ。

    pub def map(f: a -> b \ ef, l: List[a]): List[b] \ ef =
        ???

    // Exercise 3.19: リストの各要素を述語関数 `f` に従ってフィルタリングする関数 `filter` を定義せよ。

    pub def filter(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        ???

    // Exercise 3.20: リストの各要素を関数 `f` に適用して得られるリストのリストを1つのリストに連結する関数 `flatMap` を定義せよ。

    pub def flatMap(f: a -> List[b] \ ef, l: List[a]): List[b] \ ef =
        ???

    // Exercise 3.21: `flatMap` を用いて `filter` を定義せよ。

    pub def filterViaFlatMap(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        ???

    // Exercise 3.22: リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを返す関数 `addPairwise` を定義せよ。 `a`, `b` の長さが異なる場合、返すリストの長さは短いほうに一致する。

    pub def addPairwise(a: List[Int32], b: List[Int32]): List[Int32] =
        ???

    // Exercise 3.23: `addPairwise` を一般化して、リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素に関数 `f` を適用して得られたリストを返す関数 `zipWith` を定義せよ。

    pub def zipWith(f: (a, b) -> c \ ef, a: List[a], b: List[b]): List[c] \ ef =
        ???

    // Exercise 3.24: リスト `sup` の中にリスト `sub` が部分列として含まれているかどうかを判定する関数 `hasSubsequence` を定義せよ。
    // 例えば、 `Cons(1, Cons(2, Cons(3, Cons(4, Nil))))` は `Cons(1, Cons(2, Nil))`, `Cons(2, Cons(3, Nil))`, `Cons(4, Nil)` を部分列として含むが、 `Cons(1, Cons(4, Nil))` は部分列として含まない。

    pub def hasSubsequence(sup: List[a], sub: List[a]): Bool with Eq[a] =
        ???
}
