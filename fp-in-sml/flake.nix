{
  description = "fp-in-sml: Functional Programming in Scala の演習を Standard ML で解く";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.mlton
            pkgs.smlnj
            pkgs.smlfmt
            pkgs.millet
            pkgs.rlwrap
            pkgs.gnumake
          ];
        };
      });
    };
}
