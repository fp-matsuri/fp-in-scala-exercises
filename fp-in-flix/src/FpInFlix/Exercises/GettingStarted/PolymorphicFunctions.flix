pub mod FpInFlix.Exercises.GettingStarted.PolymorphicFunctions {
    // こちらは多相(ポリモーフィック)版の `findFirst` であり、
    // `a` が探している要素かどうかをテストする関数でパラメータ化されている。
    // `String` をハードコードする代わりに型 `a` をパラメータとしてとる。
    // そして、与えられたキーに対する等価判定をハードコードする代わりに
    // ベクターの個々の要素をテストする関数をとる。
    pub def findFirst(p: a -> Bool, xs: Vector[a]): Int32 =
        @Tailrec
        def loop(n) =
            if (n >= Vector.size(xs)) -1
            // 関数 `p` が現在の要素にマッチしたら、
            // 合うものが見つかったということでベクターのそのインデックスを返す。
            else if (xs |> Vector.get(n) |> p) n
            else loop(n + 1);
        loop(0)

    // Exercise 2.2: `Vector[A]` がソート済みかどうかを判定する多相関数を定義せよ。
    // 第2引数 `gt` は `xs` の隣接する2要素をとって最初の要素が2番目の要素より大きいかどうかを判定する述語関数。

    pub def isSorted(gt: (a, a) -> Bool, xs: Vector[a]): Bool =
        ???

    // 多相関数はたいてい型によって制約されているため、対応する実装がひとつしかないことがある。
    // こちらはその一例:

    pub def partial1(a: a, f: (a, b) -> c): b -> c =
        b -> f(a, b)

    // Exercise 2.3: `curry` を実装せよ。

    // `->` は右結合であるため、戻り型を `a -> b -> c` と書くこともできる。
    // NOTE: Flixでは関数は常にカリー化されるため、手動のカリー化関数は必要にならない。
    // ref. https://doc.flix.dev/functions.html#curried-by-default
    pub def curry(f: (a, b) -> c): a -> (b -> c) =
        ???

    // Exercise 2.4: `uncurry` を実装せよ。

    pub def uncurry(f: a -> b -> c): (a, b) -> c =
        ???

    /*
     * これら2つの形式を行き来できることに注目しよう。curryしてuncurryすることができ、これら2つの形式はある意味で「同じ」だといえる。
     * FPの専門用語では、これらは _同型(isomorphic)_ ("iso" = same; "morphe" = shape, form)であると言い、圏論(category theory)から引き継がれた用語だ。
     */

    // Exercise 2.5: `compose` を実装せよ。
    // NOTE: Preludeの関数合成演算子 `>>` に相当する(ただし、向きは異なる)
    // ref. https://api.flix.dev/index.html#def-%3E%3E

    pub def compose(f: b -> c, g: a -> b): a -> c =
        ???
}
