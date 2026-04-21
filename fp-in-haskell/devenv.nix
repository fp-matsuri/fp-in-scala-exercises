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
  };
}
