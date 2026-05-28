(* [either.ml] に書いた通り、OCaml での right-biased な型は {{:https://ocaml.org/manual/5.4/api/Result.html}[Stdlib.Result]} になる。
   ここでは、オリジナルに沿って、[Validated] を定義していく。 *)

type (+'e, +'a) t = Valid of 'a | Invalid of 'e list

let to_either = function
  | Valid a -> Either.Right a
  | Invalid es -> Either.Left es

let map f = function Valid a -> Valid (f a) | invalid -> invalid

(* map2 のための helper *)
let get_invalids = function Invalid es -> es | Valid _ -> []

let map2 f = function
  | Valid a, Valid b -> Valid (f a b)
  | a, b -> Invalid (get_invalids a @ get_invalids b)

(* Scala 版では [fromEither] だが、OCaml の文化では [of_] が多いので修正 *)
let of_either = function
  | Either.Right a -> Valid a
  | Either.Left es -> Invalid es

let traverse f =
  (* 通常のモジュールだけでなく、ラベル付き引数を使える [~Labels] モジュールが存在する。
     引数の順序で悩まなくていいので、特に [fold_] 系の関数で便利。
   *)
  ListLabels.fold_right
    ~f:(fun a acc -> map2 List.cons (f a, acc))
    ~init:(Valid [])

(** @see <https://ocaml.org/manual/5.4/polymorphism.html#ss:valuerestriction>
      6.1.2 The value restriction *)
let sequence x = traverse Fun.id x

module More_general = struct
  type (+'e, +'a) t = Valid of 'a | Invalid of 'e

  let to_either = function
    | Valid a -> Either.Right a
    | Invalid es -> Either.Left es

  let map f = function Valid a -> Valid (f a) | invalid -> invalid

  (* map2 のための helper *)
  let get_invalids = function Invalid e -> [ e ] | Valid _ -> []

  let map2 ~combine_errors f = function
    | Valid a, Valid b -> Valid (f a b)
    | a, b -> Invalid (combine_errors (get_invalids a) (get_invalids b))

  (* Scala 版では [fromEither] だが、OCaml の文化では [of_] が多いので修正 *)
  let of_either = function
    | Either.Right a -> Valid a
    | Either.Left es -> Invalid es

  let traverse ~combine_errors f =
    ListLabels.fold_right
      ~f:(fun a acc -> map2 ~combine_errors List.cons (f a, acc))
      ~init:(Valid [])

  let sequence = traverse Fun.id
end
