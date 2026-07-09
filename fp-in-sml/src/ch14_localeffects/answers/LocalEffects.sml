(* 第14章 解答例 (LocalEffects)．可変配列を関数の内部だけで使う． *)
structure LocalEffects: LOCAL_EFFECTS =
struct
  fun quicksort [] = []
    | quicksort xs =
        let
          val arr = Array.fromList xs
          val n = Array.length arr

          fun swap (i, j) =
            let
              val t = Array.sub (arr, i)
            in
              Array.update (arr, i, Array.sub (arr, j));
              Array.update (arr, j, t)
            end

          (* Lomuto 分割．lo..hi の範囲を pivot = arr[hi] で分ける． *)
          fun partition (lo, hi) =
            let
              val pivot = Array.sub (arr, hi)
              val store = ref lo
              fun loop j =
                if j < hi then
                  ( if Array.sub (arr, j) < pivot then
                      (swap (!store, j); store := !store + 1)
                    else
                      ()
                  ; loop (j + 1)
                  )
                else
                  ()
            in
              loop lo;
              swap (!store, hi);
              !store
            end

          fun qs (lo, hi) =
            if lo < hi then
              let val p = partition (lo, hi)
              in qs (lo, p - 1); qs (p + 1, hi)
              end
            else
              ()
        in
          qs (0, n - 1);
          Array.foldr (op::) [] arr
        end
end
