{ pkgs }:
let
  rust = pkgs.rust-analyzer;

  kclvm = pkgs.callPackage ./kclvm.nix { };
in pkgs.rustPlatform.buildRustPackage rec {
  pname = "kclvm";
  version = "0.8.5";

  src = pkgs.fetchFromGitHub {
    owner = "kcl-lang";
    repo = "kcl";
    rev = "v${version}";
    hash = "sha256-S78Oh4lI+yMBQ/KVOj0qMYVgVZU9QufjfRpB29a0iOc=";
  };
  # https://discourse.nixos.org/t/difficulty-using-buildrustpackage-with-a-src-containing-multiple-cargo-workspaces/10202/5
  sourceRoot = "source/cli";

  cargoPatches = [ ./kclvm_cli/cargo_lock.patch ];
  cargoLock.lockFile = ./kclvm_cli/Cargo.lock;

  nativeBuildInputs = [ rust ];
  buildInputs = [ kclvm ];
}
