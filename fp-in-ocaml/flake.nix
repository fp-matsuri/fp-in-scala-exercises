{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            dune
            pkg-config
            nil
            nixpkgs-fmt
          ];

          shellHook = ''
            if [ -f dune-project ]; then
              eval "$(dune tool env 2>/dev/null)" || true
            fi
          '';
        };
      }
    );
}
