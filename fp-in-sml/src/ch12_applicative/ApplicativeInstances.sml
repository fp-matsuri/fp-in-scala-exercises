(* 第12章 アプリカティブのインスタンス (演習・解答で共通)．
 * Validation は誤りを「蓄積」する．これはモナド (短絡する Either) では作れない
 * アプリカティブ特有の振る舞い． *)

structure OptionAp: APPLICATIVE =
struct
  type 'a t = 'a option
  fun unit a = SOME a
  fun map2 f (SOME a) (SOME b) =
        SOME (f (a, b))
    | map2 _ _ _ = NONE
end

structure ListAp: APPLICATIVE =
struct
  type 'a t = 'a list
  fun unit a = [a]
  fun map2 f xs ys =
    List.concat (List.map (fn a => List.map (fn b => f (a, b)) ys) xs)
end

datatype ('e, 'a) validation = Invalid of 'e list | Valid of 'a

(* 誤り型 e を固定してアプリカティブにする． *)
functor ValidationAp (type e): APPLICATIVE =
struct
  type 'a t = (e, 'a) validation
  fun unit a = Valid a
  fun map2 f va vb =
    case (va, vb) of
      (Valid a, Valid b) => Valid (f (a, b))
    | (Invalid e1, Invalid e2) => Invalid (e1 @ e2)
    | (Invalid e1, _) => Invalid e1
    | (_, Invalid e2) => Invalid e2
end
