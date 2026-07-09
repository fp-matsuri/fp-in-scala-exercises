(* 第6章 解答例 (State)． *)
structure State :> STATE =
struct
  (* 状態を受け取り (値と次の状態) を返す関数として表す． *)
  type ('s, 'a) state = 's -> 'a * 's

  (* state/run は封印した型の出入り口 (表現が関数そのものなので中身は恒等)． *)
  fun state f = f
  fun run st s = st s

  fun unit a s = (a, s)

  fun map f st s =
    let val (a, s') = st s
    in (f a, s')
    end

  fun flatMap g st s =
    let val (a, s') = st s
    in g a s'
    end

  fun map2 f sa sb =
    flatMap (fn a => map (fn b => f (a, b)) sb) sa

  fun sequence sts =
    List.foldr (fn (st, acc) => map2 (op::) st acc) (unit []) sts

  fun get s = (s, s)
  fun set s _ = ((), s)
  fun modify f s = ((), f s)
end
