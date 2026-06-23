(* 第14章 局所的な副作用 (縮小版)．
 * 本書: ST モナドで局所的可変を型に閉じ込め，外に漏れないことを保証する．
 * SML: 関数内の ref / 配列で同じことが書けるため ST は扱わない．
 * 代表例: 内部だけ可変配列で並べ替え，外からは int list -> int list の純関数． *)
signature LOCAL_EFFECTS =
sig
  (* 外からは純粋 (同じ入力には同じ出力，副作用は観測されない)． *)
  val quicksort: int list -> int list
end
