pub mod FpInFlix.Answers.Laziness.LazyList {
    use FpInFlix.Answers.Laziness.LazyList.Cons

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

    pub def toListRecursive(ll: LazyList[a]): List[a] =
        match ll {
            case Empty => Nil
            case Cons(head, tail) => head :: toListRecursive(force tail)
        }

    pub def toList(ll: LazyList[a]): List[a] =
        @Tailrec
        def go(xs, acc) =
            match xs {
                case Empty => List.reverse(acc)
                case Cons(head, tail) => go(force tail, head :: acc)
            };
        go(ll, Nil)

    pub def toListFast(ll: LazyList[a]): List[a] =
        region rc {
            let buf = MutList.empty(rc);
            @Tailrec
            def go(xs) =
                match xs {
                    case Empty => MutList.toList(buf)
                    case Cons(head, tail) => MutList.push(head, buf); go(force tail)
                };
            go(ll)
        }

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
        match ll {
            case Cons(head, tail) if n > 1 => Cons(head, lazy take(n - 1, force tail))
            case Cons(head, _) if n == 1 => Cons(head, lazy Empty)
            case _ => Empty
        }

    @Tailrec
    pub def drop(n: Int32, ll: LazyList[a]): LazyList[a] =
        match ll {
            case Cons(_, tail) if n > 0 => drop(n - 1, force tail)
            case _ => ll
        }

    // Exercise 5.3: 遅延リストの先頭から条件を満たす限り続けて要素を返す関数 `takeWhile` を定義せよ。

    pub def takeWhile(p: a -> Bool, ll: LazyList[a]): LazyList[a] =
        match ll {
            case Cons(head, tail) if p(head) => Cons(head, lazy takeWhile(p, force tail))
            case _ => Empty
        }

    // Exercise 5.4: 遅延リストのすべての要素が条件を満たすかどうかを判定する関数 `forAll` を定義せよ。

    pub def forAll(p: a -> Bool \ ef, ll: LazyList[a]): Bool \ ef =
        foldRight((x, acc) -> p(x) and acc, true, ll)

    // Exercise 5.5: `foldRight` を用いて `takeWhile` を実装せよ。

    pub def takeWhile_1(p: a -> Bool, ll: LazyList[a]): LazyList[a] =
        foldRight((x, acc) -> if (p(x)) Cons(x, lazy acc) else Empty, Empty, ll)

    // Exercise 5.6: `foldRight` を用いて先頭要素を返す関数 `headOption` を実装せよ。

    pub def headOption(ll: LazyList[a]): Option[a] =
        foldRight((x, _) -> Some(x), None, ll)

    // Exercise 5.7: `foldRight` を用いて `map`, `filter`, `append`, `flatMap` を実装せよ。

    pub def map(f: a -> b \ ef, ll: LazyList[a]): LazyList[b] \ ef =
        foldRight((x, acc) -> Cons(f(x), lazy acc), Empty, ll)

    pub def filter(p: a -> Bool \ ef, ll: LazyList[a]): LazyList[a] \ ef =
        foldRight((x, acc) -> if (p(x)) Cons(x, lazy acc) else acc, Empty, ll)

    pub def append(ll1: LazyList[a], ll2: LazyList[a]): LazyList[a] =
        foldRight((x, acc) -> Cons(x, lazy acc), ll2, ll1)

    pub def flatMap(f: a -> LazyList[b] \ ef, ll: LazyList[a]): LazyList[b] \ ef =
        foldRight((x, acc) -> append(f(x), acc), Empty, ll)

    pub def ones(): LazyList[Int32] =
        Cons(1, lazy ones())

    // Exercise 5.8: 任意の値を無限に繰り返す遅延リストを生成する関数 `continually` を定義せよ。

    pub def continually(x: a): LazyList[a] =
        Cons(x, lazy continually(x))

    // Exercise 5.9: `n` から1ずつ増える無限の遅延リストを生成する関数 `startFrom` を定義せよ。

    pub def startFrom(n: Int32): LazyList[Int32] =
        Cons(n, lazy startFrom(n + 1))

    // Exercise 5.10: フィボナッチ数の無限の遅延リストを生成する関数 `fibs` を定義せよ。

    pub def fibs(): LazyList[BigInt] =
        def go(current, next) =
            Cons(current, lazy go(next, current + next));
        go(0ii, 1ii)

    // Exercise 5.11: は初期状態 `state` 、状態から次の要素と次の状態を返す関数 `f` を受け取って遅延リストを生成する一般的な関数 `unfold` を定義せよ。

    pub def unfold(f: s -> Option[(a, s)], state: s): LazyList[a] =
        match f(state) {
            case None => Empty
            case Some((head, nextState)) => Cons(head, lazy unfold(f, nextState))
        }

    pub def unfoldViaFold(f: s -> Option[(a, s)], state: s): LazyList[a] =
        Option.foldLeft((_, p) -> Cons(fst(p), lazy unfoldViaFold(f, snd(p))), Empty, f(state))

    pub def unfoldViaMap(f: s -> Option[(a, s)], state: s): LazyList[a] =
        f(state)
            |> Option.map(p -> Cons(fst(p), lazy unfoldViaMap(f, snd(p))))
            |> Option.getWithDefault(Empty)

    // Exercise 5.12: `unfold` を用いて `fibs`, `startFrom`, `continually`, `ones` を実装せよ。

    pub def fibsViaUnfold(): LazyList[BigInt] =
        // NOTE: ラムダ式の引数でパターンマッチすることができる(ここでは2要素のタプルによる1引数)
        // ref. https://doc.flix.dev/pattern-matching.html#match-lambdas
        unfold(match (current, next) -> Some((current, (next, current + next))), (0ii, 1ii))

    pub def startFromViaUnfold(n: Int32): LazyList[Int32] =
        unfold(x -> Some((x, x + 1)), n)

    pub def continuallyViaUnfold(x: a): LazyList[a] =
        unfold(_ -> Some((x, ())), ())

    pub def onesViaUnfold(): LazyList[Int32] =
        unfold(_ -> Some((1, ())), ())

    // Exercise 5.13: `unfold` を用いて `map`, `take`, `takeWhile`, `zipWith`, `zipAll` を実装せよ。
    // `zipAll` は2つの遅延リストが両方とも尽きるまでそれぞれ先頭から順に取り出して対応する要素をペアにして返す。

    pub def mapViaUnfold(f: a -> b, ll: LazyList[a]): LazyList[b] =
        unfold(x -> match x {
            case Empty => None
            case Cons(head, tail) => Some((f(head), force tail))
        }, ll)

    pub def takeViaUnfold(n: Int32, ll: LazyList[a]): LazyList[a] =
        unfold(x -> match x {
            case (m, Cons(head, tail)) if m > 1 => Some((head, (m - 1, force tail)))
            case (m, Cons(head, _)) if m == 1 => Some((head, (0, Empty)))
            case _ => None
        }, (n, ll))

    pub def takeWhileViaUnfold(p: a -> Bool, ll: LazyList[a]): LazyList[a] =
        unfold(x -> match x {
            case Cons(head, tail) if p(head) => Some((head, force tail))
            case _ => None
        }, ll)

    pub def zipWith(f: (a, b) -> c, ll1: LazyList[a], ll2: LazyList[b]): LazyList[c] =
        unfold(x -> match x {
            case (Cons(head1, tail1), Cons(head2, tail2)) =>
                Some((f(head1, head2), (force tail1, force tail2)))
            case _ => None
        }, (ll1, ll2))

    // `zipWith` の特殊ケース
    pub def zip(ll1: LazyList[a], ll2: LazyList[b]): LazyList[(a, b)] =
        zipWith((x, y) -> (x, y), ll1, ll2)

    pub def zipAll(ll1: LazyList[a], ll2: LazyList[b]): LazyList[(Option[a], Option[b])] =
        unfold(x -> match x {
            case (Empty, Empty) => None
            case (Cons(head1, tail1), Empty) => Some(((Some(head1), None), (force tail1, Empty)))
            case (Empty, Cons(head2, tail2)) => Some(((None, Some(head2)), (Empty, force tail2)))
            case (Cons(head1, tail1), Cons(head2, tail2)) =>
                Some(((Some(head1), Some(head2)), (force tail1, force tail2)))
        }, (ll1, ll2))

    pub def zipWithAll(f: (Option[a], Option[b]) -> c, ll1: LazyList[a], ll2: LazyList[b]): LazyList[c] =
        unfold(x -> match x {
            case (Empty, Empty) => None
            case (Cons(head1, tail1), Empty) => Some((f(Some(head1), None), (force tail1, Empty)))
            case (Empty, Cons(head2, tail2)) => Some((f(None, Some(head2)), (Empty, force tail2)))
            case (Cons(head1, tail1), Cons(head2, tail2)) =>
                Some((f(Some(head1), Some(head2)), (force tail1, force tail2)))
        }, (ll1, ll2))

    // `zipWithAll` の特殊ケース
    pub def zipAllViaZipWithAll(ll1: LazyList[a], ll2: LazyList[b]): LazyList[(Option[a], Option[b])] =
        zipWithAll((x, y) -> (x, y), ll1, ll2)

    // Exercise 5.14: 定義済みの関数を用いて遅延リストが `prefix` で始まるかどうか判定する関数 `startsWith` を定義せよ。

    pub def startsWith(prefix: {prefix = LazyList[a]}, ll: LazyList[a]): Bool with Eq[a] =
        zipAll(prefix#prefix, ll)
            |> takeWhile(p -> Option.nonEmpty(fst(p)))
            |> forAll(p -> fst(p) == snd(p))

    // Exercise 5.15: `unfold` を用いて遅延リストに `tail` を繰り返し適用した結果を返す関数 `tails` を定義せよ。
    // 例えば `tails(Cons(1, Cons(2, Cons(3, Empty))))` は `Cons(Cons(1, Cons(2, Cons(3, Empty))), Cons(Cons(2, Cons(3, Empty)), Cons(Cons(3, Empty), Cons(Empty, Empty))))` を返す。

    pub def tails(ll: LazyList[a]): LazyList[LazyList[a]] =
        Cons(Empty, lazy Empty)
            |> append(unfold(x -> match x {
                case Empty => None
                case Cons(head, tail) => Some((Cons(head, tail), force tail))
            }, ll))

    pub def hasSubsequence(sub: {sub = LazyList[a]}, sup: LazyList[a]): Bool with Eq[a] =
        exists(tail -> startsWith(prefix = sub#sub, tail), tails(sup))

    // Exercise 5.16: `tails` を一般化して、 `foldRight` の累積値を要素とする遅延リストを返す関数 `scanRight` を定義せよ。

    pub def scanRight(f: (a, b) -> b \ ef, init: b, ll: LazyList[a]): LazyList[b] \ ef =
        foldRight((x, acc) ->
            let y = f(x, fst(acc));
            (y, Cons(y, lazy snd(acc))),
            (init, Cons(init, lazy Empty)),
            ll
        )
            |> snd
}
