(* MLton 用のエントリポイントです．
 * 全テストを実行し終了コードを返します．
 * SML/NJ の REPL では読み込まず CM.make の後で Test.run () を呼びます． *)
val _ = OS.Process.exit (Test.run ())
