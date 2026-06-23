(* 第14章 演習 (LocalEffects)． *)
structure LocalEffects: LOCAL_EFFECTS =
struct
  (* Exercise 14.x: 内部で Array を使った in-place クイックソートを実装せよ．
   * ヒント: Array.fromList で配列にし，添字で swap しながら整列し，
   * 最後に Array.foldr (op ::) [] でリストへ戻す．可変状態は関数の外へ漏らさない． *)
  fun quicksort xs = Stub.todo ()
end
