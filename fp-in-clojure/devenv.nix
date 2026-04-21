{ pkgs, ... }:

{
  languages.java = {
    enable = true;
    jdk.package = pkgs.jdk21;
  };

  languages.clojure.enable = true;

  packages = with pkgs; [
    git
    clj-kondo
    cljstyle
    joker
  ];

  scripts = {
    tests.exec = ''clj -X:test "$@"'';
    lint.exec = "make lint";
    fmt.exec = "cljstyle fix";
    repl.exec = "clj -M:test";
  };
}
