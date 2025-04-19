{
  rust-toolchain,
  makeRustPlatform,
  lib,
  pkg-config,
  openssl,
  ...
}: let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
  rustPlatform = makeRustPlatform {
    cargo = rust-toolchain;
    rustc = rust-toolchain;
  };
  rlinkLibs = [openssl];
in
  rustPlatform.buildRustPackage {
    inherit (cargoToml.package) version;
    pname = "bevy_lint";
    src = ./.;

    cargoBuildFlags = "--bin bevy_lint";

    cargoLock.lockFile = ./Cargo.lock;

    buildInputs = rlinkLibs;
    runtimeDependencies = rlinkLibs;

    nativeBuildInputs = [pkg-config];

    checkFlags = [
    ];

    meta = {
      description = "A collection of lints for the Bevy game engine";
      homepage = "thebevyflock.github.io/bevy_cli/";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      changelog = "https://github.com/TheBevyFlock/bevy_cli/blob/main/bevy_lint/CHANGELOG.md";
      mainProgram = "bevy_lint";
    };
  }
