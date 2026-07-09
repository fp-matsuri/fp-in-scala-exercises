(* 第4章 演習 (MyOption)．toOption / fromOption は補助なので実装済み． *)
structure MyOption: MY_OPTION =
struct
  datatype 'a t = None | Some of 'a

  fun toOption None = NONE
    | toOption (Some a) = SOME a

  fun fromOption NONE = None
    | fromOption (SOME a) = Some a

  (* Exercise 4.1: 以下を実装せよ． *)
  fun map f opt = Stub.todo ()
  fun getOrElse opt default = Stub.todo ()
  fun flatMap f opt = Stub.todo ()
  fun orElse opt other = Stub.todo ()
  fun filter p opt = Stub.todo ()

  (* Exercise 4.3: 2つの Option を関数で合成せよ． *)
  fun map2 f oa ob = Stub.todo ()

  (* Exercise 4.4: Option のリストを「全部 Some なら Some リスト」にせよ． *)
  fun sequence opts = Stub.todo ()

  (* Exercise 4.5: traverse を実装せよ (sequence は traverse で書ける)． *)
  fun traverse f xs = Stub.todo ()
end
