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
  stdenv.mkDerivation rec {
    pname = "infrastructure-agent";
    inherit version;
  
  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "infrastructure-agent";
    rev = version;
    hash = "sha256-IfPiexh6vPOFkMz1OqNouozKJoKXeQMYYhaPg/tU0sg=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.automake pkgs.libtool pkgs.git pkgs.bash pkgs.go ];

  env.NIX_CFLAGS_COMPILE = "-O2";
  env_GO_BIN_PATH = "${pkgs.go}/bin/go";

  buildPhase = ''
    export HOME=$(pwd)
    export GOPROXY="direct"

    substituteInPlace Makefile \
      --replace-quiet "go-agent/v3 v3.27.0" "go-agent/v3 v3.35.1"

cat >> go.sum<< EOF
github.com/newrelic/go-agent/v3 v3.35.1 h1:N43qBNDILmnwLDCSfnE1yy6adyoVEU95nAOtdUgG4vA=
github.com/newrelic/go-agent/v3 v3.35.1/go.mod h1:GNTda53CohAhkgsc7/gqSsJhDZjj8vaky5u+vKz7wqM=
EOF
  
    substituteInPlace Makefile \
      --replace-quiet "include \$\(INCLUDE_TOOLS_DIR\)" "\# include \$\(INCLUDE_TOOLS_DIR\)"

    substituteInPlace Makefile \  
      --replace-quiet "include \$\(INCLUDE_TEST_DIR\)" "\# include \$\(INCLUDE_TEST_DIR\)"
 
    make
  '';
  # installPhase = ''
  #    mkdir -p $out

  #    cp -r agent/.libs/newrelic.so $out/lib
  # '';
  
  doCheck = false;

  meta = {
    description = "New Relic Infrastructure Agent";
    homepage = "https://github.com/newrelic/infrastructure-agent.git";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davsanchez ];
    mainProgram = "newrelic-infra";
  };
}
