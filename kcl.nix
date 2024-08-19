{ pkgs }:
let
  kclvm = pkgs.callPackage ./kclvm.nix { };
  kclvm_cli = pkgs.callPackage ./kclvm_cli.nix { };
in pkgs.buildGoModule rec {
  pname = "kcl";
  version = "0.9.3";
  vendorHash = "sha256-AP1MOlnoTnD7luNR+1QtAdMiJL8tEEwJocT+9wBRgAo=";

  src = pkgs.fetchFromGitHub {
    owner = "kcl-lang";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-QUVTRlzG8hT+iQx5dSycbRDAyeknjwGOWynCRw3oxlo=";
  };

  subPackages = [ "cmd/kcl" ];

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = [ kclvm kclvm_cli ];

  # see https://github.com/kcl-lang/kcl-go/blob/main/pkg/env/env.go#L60
  postFixup = with pkgs; ''
     wrapProgram $out/bin/kcl \
    --set KCL_LIB_HOME ${lib.makeLibraryPath [ kclvm ]} \
    --set KCL_GO_DISABLE_INSTALL_ARTIFACT "1" \
    --set PATH ${lib.makeBinPath [ kclvm_cli ]}
  '';
  # --set KCL_GO_DISABLE_ARTIFACT_IN_PATH "false" \
}
