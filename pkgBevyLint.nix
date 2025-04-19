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
    src = ./bevy_lint/.;

    cargoLock = let
      fixupLockFile = path: builtins.readFile path;
    in {
      lockFileContents = fixupLockFile ./Cargo.lock;
    };

    # cargoLock.lockFile = ./Cargo.lock;
    cargoPatches = [
      # a patch file to add/update Cargo.lock in the source code
      ./Cargo.lock
    ];

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
