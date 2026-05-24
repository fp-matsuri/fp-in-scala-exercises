(** List.t と同様 *)
type +'a t = Leaf of 'a | Branch of 'a t * 'a t

let rec size = function Leaf _ -> 1 | Branch (l, r) -> 1 + size l + size r

(** Exercise 3.25: ツリーのリーフの最大値を計算する関数[maximum]を定義せよ。 *)
let rec maximum : int t -> int = function
  | Leaf v -> v
  | Branch (l, r) -> max (maximum l) (maximum r)

(** Exercise 3.26: ツリーの深さを計算する関数[depth]を定義せよ。 深さは、ルートから最も遠いリーフまでのパスの長さである。 *)
let rec depth : 'a t -> int = function
  | Leaf _ -> 0
  | Branch (l, r) -> 1 + max (depth l) (depth r)

(** Exercise 3.27: ツリーの各リーフに関数[f]を適用する関数[map]を定義せよ。 *)
let rec map (f : 'a -> 'b) : 'a t -> 'b t = function
  | Leaf v -> Leaf (f v)
  | Branch (l, r) -> Branch (map f l, map f r)

(** Exercise 3.28-1: ツリーのリーフの値を変換する関数[f]とブランチの左右の値をまとめる関数[g]を受け取って
    ツリーを畳み込む関数[fold]を定義せよ。 また、[fold]を用いて[size_via_fold], [depth_via_fold],
    [map_via_fold]を定義せよ。 *)
let rec fold (f : 'a -> 'b) (g : 'b * 'b -> 'b) : 'a t -> 'b = function
  | Leaf v -> f v
  | Branch (l, r) -> g (fold f g l, fold f g r)

let size_via_fold t = fold (Fun.const 1) (fun (l, r) -> 1 + l + r) t
let depth_via_fold t = fold (Fun.const 0) (fun (l, r) -> 1 + max l r) t

let map_via_fold f t =
  fold (fun v -> Leaf (f v)) (fun (l, r) -> Branch (l, r)) t

(** Exercise 3.28-2: [fold]を用いて[maximum]を定義せよ。 *)
let maximum_via_fold t = fold Fun.id (fun (l, r) -> max l r) t
