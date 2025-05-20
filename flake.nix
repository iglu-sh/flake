{
  description = "Flake for managing all packages in the iglu.sh organisation";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus?ref=afcb15b845e74ac5e998358709b2b5fe42a948d1";
  };

  # deadnix: skip
  outputs = inputs@{ self, nixpkgs, utils }:
    utils.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      overlays = {
        lib = import ./lib;
        pkgs = import ./pkgs;
      };

      sharedOverlays = [
        self.overlays.lib
        self.overlays.pkgs
      ];

      outputsBuilder = channels:
        let
          inherit (channels) nixpkgs;
        in
        {
          devShell = nixpkgs.mkShell {
            packages = with nixpkgs; [
              zsh
              wget
              cachix
              bun
              iglu.flakecheck
            ];
            shellHook = ''
              exec zsh
            '';
          };
          packages = nixpkgs.iglu;
        };
    };
}
