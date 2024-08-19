{ pkgs }:
let
  rust = pkgs.rust-analyzer;

  kclvm = pkgs.callPackage ./kclvm.nix { };
in pkgs.rustPlatform.buildRustPackage rec {
  pname = "kclvm";
  version = "0.9.3";

  src = pkgs.fetchFromGitHub {
    owner = "kcl-lang";
    repo = "kcl";
    rev = "v${version}";
    hash = "sha256-nk5oJRTBRj0LE2URJqno8AoZ+/342C2tEt8d6k2MAc8=";
  };
  # https://discourse.nixos.org/t/difficulty-using-buildrustpackage-with-a-src-containing-multiple-cargo-workspaces/10202/5
  sourceRoot = "source/cli";
  cargoPatches = [ ./kclvm_cli/cargo_lock.patch ];
  cargoLock.lockFile = ./kclvm_cli/Cargo.lock;

  nativeBuildInputs = [ rust ];
  buildInputs = [ kclvm ];
}
