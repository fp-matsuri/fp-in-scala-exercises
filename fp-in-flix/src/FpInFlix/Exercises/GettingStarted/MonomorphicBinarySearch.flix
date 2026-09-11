pub mod FpInFlix.Exercises.GettingStarted.MonomorphicBinarySearch {
    // まずは `String` に特化したfindFirst。
    // 理想的には任意の `Vector` 型に対して動作するように一般化できるだろう。
    pub def findFirst(key: String, ss: Vector[String]): Int32 =
        @Tailrec
        def loop(n) =
            // `n` がベクターの終端を過ぎたら、
            // ベクター中にそのキーは存在しないという意味で `-1` を返す。
            if (n >= Vector.size(ss)) -1
            // `Vector.get(n, ss)` はベクター `ss` のn番目の要素を取り出す。
            // `n` の位置の要素がキーと等しければ、
            // ベクターのそのインデックスに要素が現れるという意味で `n` を返す。
            else if (Vector.get(n, ss) == key) n
            else loop(n + 1);  // そうでなければ `n` をインクリメントして探索を続ける。
        // ベクターの最初の要素からループを開始する。
        loop(0)
}
