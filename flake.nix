{
  description = "A Bevy CLI tool and linter.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      perSystem = {
        self',
        pkgs,
        system,
        lib,
        ...
      }: let
        rust-toolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        mkBevyCli = import ./pkgBevyCli.nix;
        mkBevyLint = import ./pkgBevyLint.nix;

        runtimeDeps = self'.packages.bevy-cli.runtimeDependencies;
        tools = self'.packages.bevy-cli.nativeBuildInputs ++ self'.packages.bevy-cli.buildInputs ++ [rust-toolchain];
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [(import inputs.rust-overlay)];
        };

        devShells.default = pkgs.mkShell {
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath runtimeDeps}";
          packages = tools;
        };

        formatter = pkgs.alejandra;
        packages = {
          default = pkgs.symlinkJoin {
            name = "bevy-tools";

            paths = with self'.packages; [
              bevy-cli
              bevy_lint
            ];

            meta = {
              description = "Combined package for bevy-cli and bevy_lint";
            };
          };

          bevy-cli = pkgs.callPackage mkBevyCli {inherit rust-toolchain;};
          bevy_lint = pkgs.callPackage mkBevyLint {inherit rust-toolchain;};
        };
      };
    };
}
