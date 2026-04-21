{ pkgs, ... }:

{
  languages.java = {
    enable = true;
    jdk.package = pkgs.jdk21;
  };

  languages.scala = {
    enable = true;
    package = pkgs.scala_3;
  };

  packages = with pkgs; [
    sbt
    scalafmt
    metals
  ];

  scripts = {
    tests.exec = "sbt test";
    lint.exec = "sbt scalafix";
    fmt.exec = "scalafmt";
    repl.exec = "sbt console";
  };
}
