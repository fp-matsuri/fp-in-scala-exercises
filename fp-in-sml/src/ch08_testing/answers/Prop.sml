(* 第8章 解答例 (Prop)． *)
structure Prop: PROP =
struct
  datatype result = Passed | Falsified of string

  type prop = int -> Rng.rng -> result

  fun forAll g show pred =
    fn n =>
      fn rng =>
        let
          fun loop (0, _) = Passed
            | loop (k, r) =
                let val (a, r') = Gen.sample g r
                in if pred a then loop (k - 1, r') else Falsified (show a)
                end
        in
          loop (n, rng)
        end

  fun andProp (p1, p2) =
    fn n =>
      fn rng =>
        (case p1 n rng of
           Passed => p2 n rng
         | falsified => falsified)

  fun run p n rng = p n rng

  fun isPassed Passed = true
    | isPassed (Falsified _) = false
end
