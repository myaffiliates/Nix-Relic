{
  pkgs,
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  pkg-config,
  pcre,
}:
let
  version = "1.59.1";
 
in
  # stdenv.mkDerivation rec {
  buildGoModule rec {
    pname = "infrastructure-agent";
    inherit version;
  
  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "infrastructure-agent";
    rev = version;
    hash = "sha256-IfPiexh6vPOFkMz1OqNouozKJoKXeQMYYhaPg/tU0sg=";
  };

  vendorHash = "sha256-5w2pzyS5z6Zxg77UoE/c3saPHOo8+70zqlrBQb6V5FU=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.cmake pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.automake pkgs.libtool pkgs.git pkgs.bash pkgs.go ];

  env.NIX_CFLAGS_COMPILE = "-O2";
  env_GO_BIN_PATH = "${pkgs.go}/bin/go";

  preBuild = ''
    export HOME=$(pwd)
    export GOPROXY="direct"
  '';  

  buildPhase = ''
    substituteInPlace go.sum \
      --replace-quiet 'v3.27.0 h1:Z3XB49d8FKjRcGzCyViCO9itBxiLPSpwjY1HlMvgamQ=' 'v3.35.1 h1:N43qBNDILmnwLDCSfnE1yy6adyoVEU95nAOtdUgG4vA=' \
      --replace-quiet 'v3.27.0/go.mod h1:TUzePinDc0BMH4Sui66rl4SBe6yOKJ5X/bRJekwuAtM=' 'v3.35.1/go.mod h1:GNTda53CohAhkgsc7/gqSsJhDZjj8vaky5u+vKz7wqM='
  
    substituteInPlace Makefile \
      --replace-quiet 'go-agent/v3 v3.27.0' 'go-agent/v3 v3.35.1' \
      --replace-quiet 'include $(INCLUDE_TOOLS' '# include $(INCLUDE_TOOLS' \
      --replace-quiet 'include $(INCLUDE_TEST' '# include $(INCLUDE_TEST'
  '';


  installPhase = ''
     mkdir -p $out

     cp -r target/* $out/
  '';
  
  doCheck = false;

  meta = {
    description = "New Relic Infrastructure Agent";
    homepage = "https://github.com/newrelic/infrastructure-agent.git";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davsanchez ];
    mainProgram = "newrelic-infra";
  };
}
