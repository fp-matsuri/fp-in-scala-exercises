pub mod FpInFlix.Exercises.Laziness.LazyList {
    use FpInFlix.Exercises.Laziness.LazyList.Cons

    // NOTE: Flix標準ライブラリの `DelayList` に相当する
    // ref. https://api.flix.dev/DelayList.html
    pub enum LazyList[a] {
        case Empty
        // NOTE: tailを遅延評価するために `Lazy` 型を利用している
        // ref. https://doc.flix.dev/laziness.html
        case Cons(a, Lazy[LazyList[a]])
    }

    // NOTE: `LazyList[a]` の文字列表現
    // ref. https://doc.flix.dev/essential-traits.html#the-tostring-trait
    instance ToString[LazyList[a]] with ToString[a] {
        pub def toString(ll: LazyList[a]): String =
            match ll {
                case Empty => "LazyList.Empty"
                case Cons(head, _) => "LazyList.Cons(${head}, <unevaluated>)"
            }
    }

    // Exercise 5.1: 遅延リストをリストに変換する関数 `toList` を定義せよ。

    pub def toList(ll: LazyList[a]): List[a] =
        ???

    pub def foldRight(f: (a, b) -> b \ ef, z: b, ll: LazyList[a]): b \ ef =
        match ll {
            case Empty => z
            case Cons(head, tail) => f(head, foldRight(f, z, force tail))
        }

    pub def exists(p: a -> Bool \ ef, ll: LazyList[a]): Bool \ ef =
        foldRight((x, acc) -> p(x) or acc, false, ll)

    @Tailrec
    pub def find(f: a -> Bool \ ef, ll: LazyList[a]): Option[a] \ ef =
        match ll {
            case Empty => None
            case Cons(head, tail) => if (f(head)) Some(head) else find(f, force tail)
        }

    // Exercise 5.2: 遅延リストの先頭から最初の `n` 要素を返す関数 `take` 、先頭から最初の `n` 要素をスキップする関数 `drop` を定義せよ。

    pub def take(n: Int32, ll: LazyList[a]): LazyList[a] =
        ???

    pub def drop(n: Int32, ll: LazyList[a]): LazyList[a] =
        ???

    // Exercise 5.3: 遅延リストの先頭から条件を満たす限り続けて要素を返す関数 `takeWhile` を定義せよ。

    pub def takeWhile(p: a -> Bool, ll: LazyList[a]): LazyList[a] =
        ???

    // Exercise 5.4: 遅延リストのすべての要素が条件を満たすかどうかを判定する関数 `forAll` を定義せよ。

    pub def forAll(p: a -> Bool \ ef, ll: LazyList[a]): Bool \ ef =
        ???

    // Exercise 5.5: `foldRight` を用いて `takeWhile` を実装せよ。

    pub def takeWhile_1(p: a -> Bool, ll: LazyList[a]): LazyList[a] =
        ???

    // Exercise 5.6: `foldRight` を用いて先頭要素を返す関数 `headOption` を実装せよ。

    pub def headOption(ll: LazyList[a]): Option[a] =
        ???

    // Exercise 5.7: `foldRight` を用いて `map`, `filter`, `append`, `flatMap` を実装せよ。

    pub def map(f: a -> b \ ef, ll: LazyList[a]): LazyList[b] \ ef =
        ???

    pub def filter(p: a -> Bool \ ef, ll: LazyList[a]): LazyList[a] \ ef =
        ???

    pub def append(ll1: LazyList[a], ll2: LazyList[a]): LazyList[a] =
        ???

    pub def flatMap(f: a -> LazyList[b] \ ef, ll: LazyList[a]): LazyList[b] \ ef =
        ???

    pub def ones(): LazyList[Int32] =
        Cons(1, lazy ones())

    // Exercise 5.8: 任意の値を無限に繰り返す遅延リストを生成する関数 `continually` を定義せよ。

    pub def continually(x: a): LazyList[a] =
        ???

    // Exercise 5.9: `n` から1ずつ増える無限の遅延リストを生成する関数 `startFrom` を定義せよ。

    pub def startFrom(n: Int32): LazyList[Int32] =
        ???

    // Exercise 5.10: フィボナッチ数の無限の遅延リストを生成する関数 `fibs` を定義せよ。

    pub def fibs(): LazyList[BigInt] =
        ???

    // Exercise 5.11: は初期状態 `state` 、状態から次の要素と次の状態を返す関数 `f` を受け取って遅延リストを生成する一般的な関数 `unfold` を定義せよ。

    pub def unfold(f: s -> Option[(a, s)], state: s): LazyList[a] =
        ???

    // Exercise 5.12: `unfold` を用いて `fibs`, `startFrom`, `continually`, `ones` を実装せよ。

    pub def fibsViaUnfold(): LazyList[BigInt] =
        ???

    pub def startFromViaUnfold(n: Int32): LazyList[Int32] =
        ???

    pub def continuallyViaUnfold(x: a): LazyList[a] =
        ???

    pub def onesViaUnfold(): LazyList[Int32] =
        ???

    // Exercise 5.13: `unfold` を用いて `map`, `take`, `takeWhile`, `zipWith`, `zipAll` を実装せよ。
    // `zipAll` は2つの遅延リストが両方とも尽きるまでそれぞれ先頭から順に取り出して対応する要素をペアにして返す。

    pub def mapViaUnfold(f: a -> b, ll: LazyList[a]): LazyList[b] =
        ???

    pub def takeViaUnfold(n: Int32, ll: LazyList[a]): LazyList[a] =
        ???

    pub def takeWhileViaUnfold(p: a -> Bool, ll: LazyList[a]): LazyList[a] =
        ???

    pub def zipWith(f: (a, b) -> c, ll1: LazyList[a], ll2: LazyList[b]): LazyList[c] =
        ???

    pub def zipAll(ll1: LazyList[a], ll2: LazyList[b]): LazyList[(Option[a], Option[b])] =
        ???

    // Exercise 5.14: 定義済みの関数を用いて遅延リストが `prefix` で始まるかどうか判定する関数 `startsWith` を定義せよ。

    pub def startsWith(prefix: {prefix = LazyList[a]}, ll: LazyList[a]): Bool with Eq[a] =
        ???

    // Exercise 5.15: `unfold` を用いて遅延リストに `tail` を繰り返し適用した結果を返す関数 `tails` を定義せよ。
    // 例えば `tails(Cons(1, Cons(2, Cons(3, Empty))))` は `Cons(Cons(1, Cons(2, Cons(3, Empty))), Cons(Cons(2, Cons(3, Empty)), Cons(Cons(3, Empty), Cons(Empty, Empty))))` を返す。

    pub def tails(ll: LazyList[a]): LazyList[LazyList[a]] =
        ???

    pub def hasSubsequence(sub: {sub = LazyList[a]}, sup: LazyList[a]): Bool with Eq[a] =
        exists(tail -> startsWith(prefix = sub#sub, tail), tails(sup))

    // Exercise 5.16: `tails` を一般化して、 `foldRight` の累積値を要素とする遅延リストを返す関数 `scanRight` を定義せよ。

    pub def scanRight(f: (a, b) -> b \ ef, init: b, ll: LazyList[a]): LazyList[b] \ ef =
        ???
}
