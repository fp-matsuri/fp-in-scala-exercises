(* 第9章 演習 (Parser)． *)
structure Parser :> PARSER =
struct
  datatype 'a presult = Ok of 'a * int | Err of string
  type 'a parser = string -> int -> 'a presult
  datatype 'a result = Success of 'a | Failure of string

  (* p を入力文字列 s に位置 0 から適用し，Ok なら Success，Err なら Failure に変換する． *)
  fun run p s = Stub.todo ()

  (* 入力を消費せず，常に a を返して成功する． *)
  fun succeed a s i = Stub.todo ()
  (* 常に msg で失敗する． *)
  fun fail msg s i = Stub.todo ()
  (* 現在位置の1文字が pred を満たせば消費して返す．満たさない／末尾なら失敗． *)
  fun satisfy pred s i = Stub.todo ()
  (* 文字 c にちょうど一致する (satisfy で書ける)． *)
  fun char c s i = Stub.todo ()
  (* 文字列 lit にちょうど一致する． *)
  fun string lit s i = Stub.todo ()

  (* p の成功結果に f を適用する． *)
  fun map f p s i = Stub.todo ()
  (* p を実行し，その結果 a から次のパーサ f a を選んで続ける (逐次)． *)
  fun flatMap f p s i = Stub.todo ()
  (* pa, pb を順に実行し，両方成功なら f (a, b)． *)
  fun map2 f pa pb s i = Stub.todo ()
  (* pa, pb を順に実行し，結果をタプルにする． *)
  fun product (pa, pb) s i = Stub.todo ()
  (* まず p1 を試し，失敗したら p2 を試す． *)
  fun or (p1, p2) s i = Stub.todo ()

  (* p を 0 回以上できるだけ繰り返し，結果のリストを返す． *)
  fun many p s i = Stub.todo ()
  (* p を 1 回以上繰り返す (0 回なら失敗)． *)
  fun many1 p s i = Stub.todo ()
  (* p をちょうど n 回繰り返す． *)
  fun listOfN n p s i = Stub.todo ()
  (* sep 区切りで p を 0 個以上並べたものを読む (区切りの結果は捨てる)． *)
  fun sepBy p sep s i = Stub.todo ()

  (* thunk () を実行時まで遅延して適用する (再帰文法用)． *)
  fun lazy thunk s i = Stub.todo ()
end
