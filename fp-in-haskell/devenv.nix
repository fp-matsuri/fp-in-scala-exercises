{ pkgs, ... }:

{
  languages.haskell = {
    enable = true;
    package = pkgs.ghc;
  };

  packages = with pkgs; [
    cabal-install
    haskellPackages.hlint
    haskellPackages.ormolu
    haskell-language-server
  ];

  scripts = {
    tests.exec = "cabal test";
    lint.exec = ''hlint $(find src -name "*.hs")'';
    fmt.exec = ''ormolu --mode inplace $(find src -name "*.hs")'';
    repl.exec = "cabal repl";
  };
}
