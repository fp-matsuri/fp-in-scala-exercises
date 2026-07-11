(* 第7章 純粋関数型の並列処理

   Scala 版では java.util.concurrent の [ExecutorService] と [Future] を利用するが、
   OCaml の標準ライブラリには対応する機能がないため、[Thread] ベースの簡易な実装
   ([Executor], [Future]) を自前で用意している。

   OCaml 5 の systhreads (Thread) は同一ドメイン内ではランタイムロックを共有するため
   並列には実行されない (並行実行のみ)。ただし本章の目的は並列計算を「記述」する
   API の設計であり、そのセマンティクスは Thread でも表現できる。
   真の並列実行が必要な場合は [Domain] や domainslib を利用する。

   なお Exercise 7.3 (タイムアウトを考慮した map2) は Java の
   [Future.get(timeout, unit)] という機構が前提であり、この簡易実装には
   対応する機能がないため省略している。 *)

(** 計算結果をあとから取得できる入れ物。[java.util.concurrent.Future] の簡易版。 *)
module Future : sig
  type 'a t

  val completed : 'a -> 'a t
  (** 完了済みの Future を作る。Scala 版の [UnitFuture] に相当。 *)

  val get : 'a t -> 'a
  (** 計算が完了するまでブロックして結果を取り出す。 計算が例外で終わっていた場合はその例外を送出する。 *)

  val is_done : 'a t -> bool

  val create : unit -> 'a t
  (** 未完了の Future を作る。[Executor] が利用する内部 API。 *)

  val deliver : 'a t -> ('a, exn) result -> unit
  (** 結果を書き込み、待機中のスレッドを起こす。[Executor] が利用する内部 API。 *)
end = struct
  type 'a state = Pending | Resolved of ('a, exn) result
  type 'a t = { mutex : Mutex.t; cond : Condition.t; mutable state : 'a state }

  let create () =
    { mutex = Mutex.create (); cond = Condition.create (); state = Pending }

  let completed a =
    {
      mutex = Mutex.create ();
      cond = Condition.create ();
      state = Resolved (Ok a);
    }

  let deliver fut result =
    Mutex.lock fut.mutex;
    fut.state <- Resolved result;
    (* [broadcast] で待機中のすべてのスレッドを起こす *)
    Condition.broadcast fut.cond;
    Mutex.unlock fut.mutex

  let get fut =
    Mutex.lock fut.mutex;
    let rec wait () =
      match fut.state with
      (* [Condition.wait] はミューテックスを解放して通知を待ち、 起こされたら再度ロックを取得して戻ってくる *)
      | Pending ->
          Condition.wait fut.cond fut.mutex;
          wait ()
      | Resolved r -> r
    in
    let r = wait () in
    Mutex.unlock fut.mutex;
    match r with Ok a -> a | Error e -> raise e

  let is_done fut =
    Mutex.lock fut.mutex;
    let d = match fut.state with Pending -> false | Resolved _ -> true in
    Mutex.unlock fut.mutex;
    d
end

(** 固定サイズのスレッドプール。[java.util.concurrent.ExecutorService] の簡易版。 *)
module Executor : sig
  type t

  val make : int -> t
  (** 指定した数のワーカースレッドを持つプールを作る *)

  val submit : t -> (unit -> 'a) -> 'a Future.t
  (** タスクをキューに追加し、結果を受け取るための Future を返す *)

  val shutdown : t -> unit
  (** キューに残ったタスクの完了を待ってすべてのワーカーを停止する *)
end = struct
  type t = {
    mutex : Mutex.t;
    cond : Condition.t;
    tasks : (unit -> unit) Queue.t;
    mutable stopped : bool;
    mutable workers : Thread.t list;
  }

  let rec worker_loop pool =
    Mutex.lock pool.mutex;
    while Queue.is_empty pool.tasks && not pool.stopped do
      Condition.wait pool.cond pool.mutex
    done;
    if Queue.is_empty pool.tasks then
      (* 停止指示済みかつタスクなし: ワーカーを終了する *)
      Mutex.unlock pool.mutex
    else begin
      let task = Queue.pop pool.tasks in
      Mutex.unlock pool.mutex;
      task ();
      worker_loop pool
    end

  let make size =
    let pool =
      {
        mutex = Mutex.create ();
        cond = Condition.create ();
        tasks = Queue.create ();
        stopped = false;
        workers = [];
      }
    in
    pool.workers <- List.init size (fun _ -> Thread.create worker_loop pool);
    pool

  let submit pool f =
    let future = Future.create () in
    let task () =
      let result = try Ok (f ()) with e -> Error e in
      Future.deliver future result
    in
    Mutex.lock pool.mutex;
    Queue.push task pool.tasks;
    Condition.signal pool.cond;
    Mutex.unlock pool.mutex;
    future

  let shutdown pool =
    Mutex.lock pool.mutex;
    pool.stopped <- true;
    Condition.broadcast pool.cond;
    Mutex.unlock pool.mutex;
    List.iter Thread.join pool.workers
end

type 'a t = Executor.t -> 'a Future.t
(** 並列計算の記述。[Executor.t] を受け取って [Future.t] を返す関数として表現する (Exercise 7.2 「Par
    の表現を考えよ」の解答に相当)。 *)

(** 並列計算を実際に実行して結果を取り出す *)
let run (es : Executor.t) (pa : 'a t) : 'a = Future.get (pa es)

(** 定数値をそのまま返す並列計算。[Executor] を利用せず、常に完了済みの Future を返す。 *)
let unit (a : 'a) : 'a t = fun _ -> Future.completed a

(* [map2] は [f] の適用自体を別スレッドで評価しない。並列性の制御は [fork] だけが
   担うという設計方針のため。[f] の評価を別スレッドで行いたい場合は
   [fork (lazy (map2 f a b))] とすればよい。 *)
let map2 (f : 'a -> 'b -> 'c) (pa : 'a t) (pb : 'b t) : 'c t =
 fun es ->
  let fa = pa es in
  let fb = pb es in
  Future.completed (f (Future.get fa) (Future.get fb))

(* もっとも素朴な [fork] の実装。ただし外側のタスクが内側のタスクの完了を待って
   ブロックするため、1つの計算にワーカースレッドを2つ消費してしまう。
   固定サイズのプールでは [fork] の入れ子がプールのサイズを超えるとデッドロックする。
   この問題は本章の後半で議論される (Scala 版 Nonblocking.scala を参照)。 *)
let fork (pa : 'a t Lazy.t) : 'a t =
 fun es -> Executor.submit es (fun () -> run es (Lazy.force pa))

(* Scala の名前渡し引数 (=> A) は OCaml では [Lazy.t] で表現する *)
let lazy_unit (a : 'a Lazy.t) : 'a t = fork (lazy (unit (Lazy.force a)))

(** [fork] と異なりワーカースレッドを消費せず、評価だけを [run] まで遅延する *)
let delay (pa : 'a t Lazy.t) : 'a t = fun es -> Lazy.force pa es

(** Exercise 7.4: [lazy_unit] を用いて、任意の関数 [f] を非同期に結果を評価する関数に変換する[async_f]を実装せよ。
*)
let async_f (_f : 'a -> 'b) : 'a -> 'b t = failwith "Not implemented"

let map (f : 'a -> 'b) (pa : 'a t) : 'b t = map2 (fun a () -> f a) pa (unit ())
let sort_par (p : int list t) : int list t = map (List.sort compare) p

(** Exercise 7.5: Par のリストを1つの Par にまとめる[sequence]を実装せよ。

    - [sequence_right]: リストを右からたどり、再帰のステップを [fork] で別スレッドに逃がす実装
    - [sequence_balanced]: 配列を半分に分割して両側を並列に処理する実装
    - [sequence]: [sequence_balanced] を利用したリスト向けのインターフェース *)

let rec sequence_right (_ps : 'a t list) : 'a list t =
  failwith "Not implemented"

let rec sequence_balanced (_ps : 'a t array) : 'a array t =
  failwith "Not implemented"

let sequence (_ps : 'a t list) : 'a list t = failwith "Not implemented"

(* リストの各要素への関数適用を並列に行う。1つの [fork] で包むことで、
   [par_map] の呼び出し自体は即座に返る *)
let par_map (f : 'a -> 'b) (ps : 'a list) : 'b list t =
  fork (lazy (sequence (List.map (async_f f) ps)))

(** Exercise 7.6: リストの要素の絞り込みを並列で行う[par_filter]を実装せよ。 *)
let par_filter (_p : 'a -> bool) (_ps : 'a list) : 'a list t =
  failwith "Not implemented"

(** 2つの並列計算が同じ結果になるかを確認する *)
let equal (es : Executor.t) (p1 : 'a t) (p2 : 'a t) : bool =
  run es p1 = run es p2

(* [cond] の結果を待ってから実行する側の計算を選ぶ *)
let choice (cond : bool t) (if_true : 'a t) (if_false : 'a t) : 'a t =
 fun es -> if run es cond then if_true es else if_false es

(** Exercise 7.11: [n] の結果を添字としてリストから計算を選ぶ[choice_n]を実装せよ。
    また、[choice_n]を用いて[choice_via_choice_n]を実装せよ。 *)

let choice_n (_n : int t) (_choices : 'a t list) : 'a t =
  failwith "Not implemented"

let choice_via_choice_n (_cond : bool t) (_if_true : 'a t) (_if_false : 'a t) :
    'a t =
  failwith "Not implemented"

(** Exercise 7.12: [key] の結果をキーとして連想リストから計算を選ぶ[choice_map]を実装せよ。 (Scala 版の [Map]
    の代わりに連想リストを利用する) *)
let choice_map (_key : 'k t) (_choices : ('k * 'v t) list) : 'v t =
  failwith "Not implemented"

(** Exercise 7.13: [choice], [choice_n], [choice_map] を一般化した[chooser]を実装せよ。
    また、[chooser]を用いて[choice_via_chooser], [choice_n_via_chooser]を実装せよ。 *)

let chooser (_f : 'a -> 'b t) (_pa : 'a t) : 'b t = failwith "Not implemented"

let choice_via_chooser (_cond : bool t) (_if_true : 'a t) (_if_false : 'a t) :
    'a t =
  failwith "Not implemented"

let choice_n_via_chooser (_n : int t) (_choices : 'a t list) : 'a t =
  failwith "Not implemented"

(* [chooser] は一般に flatMap や bind と呼ばれる *)
let flat_map (f : 'a -> 'b t) (pa : 'a t) : 'b t = chooser f pa

(** Exercise 7.14: 入れ子になった並列計算を平坦化する[join]を実装せよ。
    また、[flat_map]を用いた[join_via_flat_map]、[join]を用いた [flat_map_via_join]も実装せよ。 *)

let join (_ppa : 'a t t) : 'a t = failwith "Not implemented"
let join_via_flat_map (_ppa : 'a t t) : 'a t = failwith "Not implemented"

let flat_map_via_join (_f : 'a -> 'b t) (_pa : 'a t) : 'b t =
  failwith "Not implemented"

module Examples = struct
  (* 本章冒頭の例: 分割統治による合計。
     配列 ([Array]) はリストと異なり、半分への分割が効率的に行える。
     この時点ではまだ並列化されていないことに注意。 *)
  let rec sum (ints : int array) : int =
    if Array.length ints <= 1 then if Array.length ints = 0 then 0 else ints.(0)
    else begin
      let mid = Array.length ints / 2 in
      let l = Array.sub ints 0 mid in
      let r = Array.sub ints mid (Array.length ints - mid) in
      sum l + sum r
    end
end
