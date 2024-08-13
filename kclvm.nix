{ pkgs }:
let rust = pkgs.rust-analyzer;
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
  sourceRoot = "source/kclvm";

  cargoLock.lockFile = ./kclvm/Cargo.lock;
  cargoLock.outputHashes = {
    "inkwell-0.2.0" = "sha256-JxSlhShb3JPhsXK8nGFi2uGPp8XqZUSiqniLBrhr+sM=";
  };

  nativeBuildInputs = [ rust pkgs.rustc ];
  buildInputs = with pkgs; [
    clang
    # Replace llvmPackages with llvmPackages_X, where X is the latest LLVM version (at the time of writing, 16)
    llvmPackages_12.bintools
    glibc
    glibmm
    libxml2
    ncurses5
    protobuf
    rustc
  ];

  patches = [ ./kclvm/enable_protoc_env.patch ];
  # preBuild = ''
  # '';

  LLVM_SYS_120_PREFIX = pkgs.llvmPackages_12.llvm.dev;
  PROTOC = "${pkgs.protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${pkgs.protobuf}/include";

  LIBCLANG_PATH =
    pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_12.libclang.lib ];
  # Add glibc, clang, glib, and other headers to bindgen search path
  BINDGEN_EXTRA_CLANG_ARGS =
    # Includes normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      # add dev libraries here (e.g. pkgs.libvmi.dev)
      # pkgs.glibc.dev
    ])
    # Includes with special directory paths
    ++ [
      ''
        -I"${pkgs.llvmPackages_12.libclang.lib}/lib/clang/${pkgs.llvmPackages_12.libclang.version}/include"''
      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      "-I${pkgs.glib.out}/lib/glib-2.0/include/"
    ];
}
