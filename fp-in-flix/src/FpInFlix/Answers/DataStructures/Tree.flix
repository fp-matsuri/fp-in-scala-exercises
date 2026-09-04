pub mod FpInFlix.Answers.DataStructures.Tree {
    pub enum Tree[a] with Eq, ToString {
        case Leaf(a)
        case Branch(Tree[a], Tree[a])
    }

    pub def size(t: Tree[a]): Int32 =
        match t {
            case Leaf(_) => 1
            case Branch(left, right) => 1 + size(left) + size(right)
        }

    pub def firstPositive(t: Tree[Int32]): Int32 =
        match t {
            case Leaf(i) => i
            case Branch(left, right) =>
                let lpos = firstPositive(left);
                if (lpos > 0) lpos else firstPositive(right)
        }

    // Exercise 3.25: ツリーのリーフの最大値を計算する関数 `maximum` を定義せよ。

    pub def maximum(t: Tree[Int32]): Int32 =
        match t {
            case Leaf(n) => n
            case Branch(left, right) => Int32.max(maximum(left), maximum(right))
        }

    // Exercise 3.26: ツリーの深さを計算する関数 `depth` を定義せよ。深さは、ルートから最も遠いリーフまでのパスの長さである。

     pub def depth(t: Tree[a]): Int32 =
        match t {
            case Leaf(_) => 0
            case Branch(left, right) => 1 + Int32.max(depth(left), depth(right))
        }

    // Exercise 3.27: ツリーの各リーフに関数 `f` を適用する関数 `map` を定義せよ。

    pub def map(f: a -> b \ ef, t: Tree[a]): Tree[b] \ ef =
        match t {
            case Leaf(a) => Leaf(f(a))
            case Branch(left, right) => Branch(map(f, left), map(f, right))
        }

    // Exercise 3.28: ツリーのリーフの値を変換する関数 `f` とブランチの左右の値をまとめる関数 `g` を受け取ってツリーを畳み込む関数 `fold` を定義せよ。
    // また、 `fold` を用いて `size` 、 `depth` 、 `map` 、 `maximum` を定義せよ。

    pub def fold(f: a -> b \ ef1, g: (b, b) -> b \ ef2, t: Tree[a]): b \ ef1 + ef2 =
        match t {
            case Leaf(a) => f(a)
            case Branch(left, right) => g(fold(f, g, left), fold(f, g, right))
        }

    pub def sizeViaFold(t: Tree[a]): Int32 =
        fold(constant(1), (l, r) -> 1 + l + r, t)

    pub def depthViaFold(t: Tree[a]): Int32 =
        fold(constant(0), (l, r) -> 1 + Int32.max(l, r), t)

    pub def mapViaFold(f: a -> b \ ef, t: Tree[a]): Tree[b] \ ef =
        fold(f >> Leaf, (l, r) -> Branch(l, r), t)

    pub def maximumViaFold(t: Tree[Int32]): Int32 =
        fold(identity, Int32.max, t)
}
