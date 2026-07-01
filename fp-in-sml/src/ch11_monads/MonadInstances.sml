(* 第11章 モナドのインスタンス (演習・解答で共通)．
 * unit / flatMap を与えるだけの薄い配線．派生関数は MonadUtil が作る．
 * State は型引数が2つ (s, a) あるので，s を functor で固定して 'a t にする． *)

structure OptionMonad: MONAD =
struct
  type 'a t = 'a option
  fun unit a = SOME a
  fun flatMap _ NONE = NONE
    | flatMap f (SOME a) = f a
end

structure ListMonad: MONAD =
struct
  type 'a t = 'a list
  fun unit a = [a]
  fun flatMap f xs =
    List.concat (List.map f xs)
end

(* 状態型 s を固定して State をモナドにする． *)
functor StateMonadFn (type s): MONAD =
struct
  type 'a t = (s, 'a) State.state
  val unit = State.unit
  val flatMap = State.flatMap
end
