(* 軽量なテスト実行基盤です．
 *
 * - 各テストファイルはロード時に `Test.register name body` でテストを登録します．
 * - `Main.sml` の `Test.run ()` が登録順に実行し，結果を集計して終了コードを返します．
 * - アサーション:
 *     assertEqual    → 等値型 (''a) 同士の比較
 *     assertEqualBy  → 非等値型 (real / 関数 / :> で隠した型 / State / LazyList など) 向けに eq と show を明示
 *     assertBool     → 真偽値の検証
 *     expectExn      → 例外が投げられたことの確認
 *     forAll         → Pbt のジェネレータで乱入力プロパティ検査 (反例を表示)
 * - 未実装を表す例外 `Stub.Todo` は todo (未実装) として FAIL とは区別して表示します．
 *)
structure Test:
sig
  val assertBool: string -> bool -> unit
  val assertEqual: ''a * ''a -> unit
  val assertEqualBy: {eq: 'a * 'a -> bool, show: 'a -> string}
                     -> 'a * 'a
                     -> unit
  val expectExn: (unit -> 'a) -> unit
  val forAll: ('a -> string) -> 'a Pbt.gen -> ('a -> bool) -> unit
  val register: string -> (unit -> unit) -> unit
  val run: unit -> OS.Process.status
end =
struct
  exception Assertion of string

  fun assertBool msg b =
    if b then () else raise Assertion msg

  fun assertEqual (a, b) =
    if a = b then () else raise Assertion "値が一致しません"

  fun assertEqualBy {eq, show} (a, b) =
    if eq (a, b) then ()
    else raise Assertion ("不一致: " ^ show a ^ " <> " ^ show b)

  fun expectExn thunk =
    ( ignore (thunk ())
    ; raise Assertion "例外が送出されませんでした"
    )
    handle
      Stub.Todo => raise Stub.Todo
    | Assertion m => raise Assertion m
    | _ => () (* 期待どおり何らかの例外 *)

  fun forAll show g pred =
    case Pbt.findCounterexample g pred of
      NONE => ()
    | SOME x => raise Assertion ("反例: " ^ show x)

  val tests: (string * (unit -> unit)) list ref = ref []

  fun register name body =
    tests := (name, body) :: !tests

  fun run () =
    let
      val all = List.rev (!tests)
      val args = CommandLine.arguments ()
      fun selected name =
        null args orelse List.exists (fn a => String.isSubstring a name) args
      val chosen = List.filter (fn (n, _) => selected n) all

      val nPass = ref 0
      val nFail = ref 0
      val nTodo = ref 0

      fun runOne (name, body) =
        (body (); nPass := !nPass + 1; print ("  ok    " ^ name ^ "\n"))
        handle
          Stub.Todo => (nTodo := !nTodo + 1; print ("  todo  " ^ name ^ "\n"))
        | Assertion m =>
            (nFail := !nFail + 1; print ("  FAIL  " ^ name ^ ": " ^ m ^ "\n"))
        | e =>
            ( nFail := !nFail + 1
            ; print ("  ERROR " ^ name ^ ": " ^ exnMessage e ^ "\n")
            )
    in
      List.app runOne chosen;
      print (concat
        [ "\n"
        , Int.toString (!nPass)
        , " ok, "
        , Int.toString (!nFail)
        , " failed, "
        , Int.toString (!nTodo)
        , " todo\n"
        ]);
      if !nFail = 0 then OS.Process.success else OS.Process.failure
    end
end
