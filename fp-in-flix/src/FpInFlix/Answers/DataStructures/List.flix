pub mod FpInFlix.Answers.DataStructures.List {
    use FpInFlix.Answers.DataStructures.List.{Cons, Nil}

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
        use FpInFlix.Answers.DataStructures.{List => MyList}

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
        }  // => 3
    // 3番目の分岐にマッチし、 `x` が1、 `y` が2に束縛される。

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

    /*
     * 入力のリストが空の場合に `Nil` を返すこともできるが、ここではエラー終了させることを選んだ。
     * これはある種の主観的な判断だ。
     * 我々の経験では、空リストのtailを取るのはたいていバグであり、静かに値を返してしまうと後になって
     * (それも発生箇所から離れたところで)このバグが発見されることになる。
     */
    pub def tail(l: List[a]): List[a] \ Abort =
        match l {
            // NOTE: Flixでは、エラー終了を標準ライブラリのエフェクト `Abort` やユーザー定義エフェクトで実現することができる。
            // Javaとの相互運用向けに例外のthrow/try-catchの機能も存在するが、Flixに閉じたプログラムでは利用しない。
            // また、有効値の有無や成否の区別を値で表すエラーハンドリングは `ErrorHandling` (第4章)モジュールで扱う。
            // ref. https://api.flix.dev/Abort.html
            case Nil => Abort.abort(RichString.text("tail of empty list"))
            // パターンで不要な変数には `_` を使うことで無視する意図を表せる。
            // NOTE: Flixでは未使用変数がコンパイルエラーになる。
            case Cons(_, t) => t
        }

    // Exercise 3.3: リストの先頭要素を別の値に置き換える関数 `setHead` を定義せよ。

    pub def setHead(l: List[a], h: a): List[a] \ Abort =
        match l {
            case Nil => Abort.abort(RichString.text("setHead on empty list"))
            case Cons(_, t) => Cons(h, t)
        }

    // Exercise 3.4: リストの先頭から `n` 個の要素を取り除く関数 `drop` を定義せよ。

    @Tailrec
    pub def drop(n: Int32, l: List[a]): List[a] =
        if (n <= 0) l
        else match l {
            case Nil => Nil
            case Cons(_, t) => drop(n - 1, t)
        }

    // Exercise 3.5: リストの先頭から条件を満たす限り続けて要素を取り除く関数 `dropWhile` を定義せよ。

    @Tailrec
    pub def dropWhile(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        match l {
            case Cons(h, t) => if(f(h)) dropWhile(f, t) else l
            case _ => l
        }

    // Exercise 3.6: 末尾要素以外のリストを返す関数 `init` を定義せよ。

    /*
     * リスト全体を最終要素までコピーしていることに注目。
     * 非効率だが自然な再帰的な実装であり、リストの要素ごとにスタックフレームを使うため、大きなリストでスタックオーバーフローになりうる。
     * 関数の内部で一時的に可変コレクションを使うというのが一般的な回避策だ。
     * 可変コレクションが関数内に閉じ込められている限り、その状態の変更は外から観測できず、参照透過性は保たれる。
     */
    pub def init(l: List[a]): List[a] \ Abort =
        match l {
            case Nil => Abort.abort(RichString.text("init of empty list"))
            case Cons(_, Nil) => Nil
            case Cons(h, t) => Cons(h, init(t))
        }

    pub def init2(l: List[a]): List[a] \ Abort =
        // NOTE: `region` ブロックの中で局所的に `MutList` を利用している
        // ref. https://doc.flix.dev/mutable-collections.html
        region rc {
            let buf = MutList.empty(rc);
            @Tailrec
            def go(cur) =
                match cur {
                    case Nil => Abort.abort(RichString.text("init of empty list"))
                    case Cons(_, Nil) => MutList.toList(buf) |> FlixList.toList
                    case Cons(h, t) => MutList.push(h, buf); go(t)
                };
            go(l)
        }

    // Exercise 3.7: `foldRight` によるリストの走査を途中で打ち切る(短絡的に結果を返す)ことは可能か? それはなぜか?

    /*
     * この `foldRight` の実装では入力のリストを最終要素まで評価しなければならないため、
     * 特定の条件で再帰を中止して値を返すようなことはできない。
     */

    // Exercise 3.8: `foldRight` の引数 `acc` に `Nil` 、 `f` に `Cons` を与えるとどのような結果が得られるか? (推測してからREPLで確認してみよう)

    /*
     * `foldRight` の引数 `acc` に `Nil` 、 `f` に `Cons` を指定すると、もとのリストがそのまま得られる。
     *
     * foldRight(Cons, Nil, Cons(1, Cons(2, Cons(3, Nil))))
     * => Cons(1, Cons(2, Cons(3, Nil)))
     *
     * `foldRight` とはリストのデータコンストラクタ `Nil`, `Cons` を引数 `acc`, `f` で置き換える操作と考えることができる。
     */

    // Exercise 3.9: リストの要素数を数える関数 `length` を定義せよ。

    pub def length(l: List[a]): Int32 =
        foldRight((_, acc) -> acc + 1, 0, l)

    // Exercise 3.10: リストを左端から畳み込む `foldLeft` 関数を末尾再帰関数として定義せよ。

    @Tailrec
    pub def foldLeft(f: (b, a) -> b \ ef, acc: b, l: List[a]): b \ ef =
        match l {
            case Nil => acc
            case Cons(h, t) => foldLeft(f, f(acc, h), t)
        }

    // Exercise 3.11: `foldLeft` を用いて `sum`, `product`, `length` を定義せよ。

    pub def sumViaFoldLeft(l: List[Int32]): Int32 =
        foldLeft((+), 0, l)

    pub def productViaFoldLeft(l: List[Float64]): Float64 =
        foldLeft((*), 1.0, l)

    pub def lengthViaFoldLeft(l: List[a]): Int32 =
        foldLeft((acc, _) -> acc + 1, 0, l)

    // Exercise 3.12: `foldLeft` を用いてリストを逆順にする関数 `reverse` を定義せよ。

    pub def reverse(l: List[a]): List[a] =
        foldLeft((acc, h) -> Cons(h, acc), Nil, l)

    // Exercise 3.13: `foldLeft` を用いて `foldRight` を定義することは可能か? 可能であれば定義せよ。

    pub def foldRightViaFoldLeft(f: (a, b) -> b \ ef, acc: b, l: List[a]): b \ ef =
        foldLeft((a, b) -> f(b, a), acc, reverse(l))

    // Exercise 3.14: `foldRight` を用いて `append` を定義せよ。

    pub def appendViaFoldRight(l1: List[a], l2: List[a]): List[a] =
        foldRight(Cons, l2, l1)

    // Exercise 3.15: `foldRight` を用いてリストのリストを1つのリストに連結する関数 `concat` を定義せよ。

    pub def concat(ls: List[List[a]]): List[a] =
        foldRight(append, Nil, ls)

    // Exercise 3.16: `foldRight` を用いてリストの各要素に1を加える関数 `incrementEach` を定義せよ。

    pub def incrementEach(l: List[Int32]): List[Int32] =
        foldRight((i, acc) -> Cons(i + 1, acc), Nil, l)

    // Exercise 3.17: `foldRight` を用いてリストの各要素の数値を文字列に変換する関数 `doubleToString` を定義せよ。

    pub def doubleToString(l: List[Float64]): List[String] =
        foldRight((d, acc) -> Cons("${d}", acc), Nil, l)

    // Exercise 3.18: `doubleToString` を一般化して、リストの各要素に関数 `f` を適用する関数 `map` を定義せよ。

    pub def map(f: a -> b \ ef, l: List[a]): List[b] \ ef =
        foldRight((h, t) -> Cons(f(h), t), Nil, l)

    pub def map2(f: a -> b \ ef, l: List[a]): List[b] \ ef =
        foldRightViaFoldLeft((h, t) -> Cons(f(h), t), Nil, l)

    pub def map3(f: a -> b \ ef, l: List[a]): List[b] \ ef =
        region rc {
            let buf = MutList.empty(rc);
            @Tailrec
            def go(xs) =
                match xs {
                    case Nil => MutList.toList(buf) |> FlixList.toList
                    case Cons(h, t) => MutList.push(f(h), buf); go(t)
                };
            go(l)
        }

    // Exercise 3.19: リストの各要素を述語関数 `f` に従ってフィルタリングする関数 `filter` を定義せよ。

    pub def filter(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        foldRight((h, t) -> if (f(h)) Cons(h, t) else t, Nil, l)

    pub def filter2(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        foldRightViaFoldLeft((h, t) -> if (f(h)) Cons(h, t) else t, Nil, l)

    pub def filter3(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        region rc {
            let buf = MutList.empty(rc);
            @Tailrec
            def go(xs) =
                match xs {
                    case Nil => MutList.toList(buf) |> FlixList.toList
                    case Cons(h, t) => if (f(h)) MutList.push(h, buf) else (); go(t)
                };
            go(l)
        }

    // Exercise 3.20: リストの各要素を関数 `f` に適用して得られるリストのリストを1つのリストに連結する関数 `flatMap` を定義せよ。

    pub def flatMap(f: a -> List[b] \ ef, l: List[a]): List[b] \ ef =
        concat(map(f, l))

    // Exercise 3.21: `flatMap` を用いて `filter` を定義せよ。

    pub def filterViaFlatMap(f: a -> Bool \ ef, l: List[a]): List[a] \ ef =
        flatMap(x -> if (f(x)) Cons(x, Nil) else Nil, l)

    // Exercise 3.22: リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素を足し合わせたリストを返す関数 `addPairwise` を定義せよ。 `a`, `b` の長さが異なる場合、返すリストの長さは短いほうに一致する。

    pub def addPairwise(a: List[Int32], b: List[Int32]): List[Int32] =
        match (a, b) {
            case (Nil, _) => Nil
            case (_, Nil) => Nil
            case (Cons(h1, t1), Cons(h2, t2)) => Cons(h1 + h2, addPairwise(t1, t2))
        }

    // Exercise 3.23: `addPairwise` を一般化して、リスト `a`, `b` をそれぞれ先頭から順に取り出して対応する要素に関数 `f` を適用して得られたリストを返す関数 `zipWith` を定義せよ。

    pub def zipWith(f: (a, b) -> c \ ef, a: List[a], b: List[b]): List[c] \ ef =
        match (a, b) {
            case (Nil, _) => Nil
            case (_, Nil) => Nil
            case (Cons(h1, t1), Cons(h2, t2)) => Cons(f(h1, h2), zipWith(f, t1, t2))
        }

    // Exercise 3.24: リスト `sup` の中にリスト `sub` が部分列として含まれているかどうかを判定する関数 `hasSubsequence` を定義せよ。
    // 例えば、 `Cons(1, Cons(2, Cons(3, Cons(4, Nil))))` は `Cons(1, Cons(2, Nil))`, `Cons(2, Cons(3, Nil))`, `Cons(4, Nil)` を部分列として含むが、 `Cons(1, Cons(4, Nil))` は部分列として含まない。

    @Tailrec
    def startWith(l: List[a], prefix: List[a]): Bool with Eq[a] =
        match (l, prefix) {
            case (_, Nil) => true
            case (Cons(h1, t1), Cons(h2, t2)) if h1 == h2 => startWith(t1, t2)
            case _ => false
        }

    @Tailrec
    pub def hasSubsequence(sup: List[a], sub: List[a]): Bool with Eq[a] =
        match sup {
            case Nil => sub == Nil
            case _ if startWith(sup, sub) => true
            case Cons(_, t) => hasSubsequence(t, sub)
        }
}
