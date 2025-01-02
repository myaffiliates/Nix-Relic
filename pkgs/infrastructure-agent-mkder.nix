{
  pkgs,
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  pcre,
}:
stdenv.mkDerivation rec {
  pname = "infrastructure-agent";
  version = "1.59.0";

  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "infrastructure-agent";
    rev = version;
    hash = "sha256-Kf7C4vJXjoJB+B695DQA3XWtm8IuBby8sKqH7F68Oy8=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.automake pkgs.libtool pkgs.git pkgs.bash pkgs.go ];

  buildPhase = ''
    export HOME=$(pwd)
    export GOPROXY="direct"

    substituteInPlace Makefile \
      --replace-quiet "go" "${pkgs.go}/bin/go"

    substituteInPlace Makefile \
      --replace-quiet "include \$\(INCLUDE_TEST_DIR\)" "\# include \$\(INCLUDE_TEST_DIR\)"
    
    substituteInPlace Makefile \
      --replace-quiet "include \$\(INCLUDE_TOOLS_DIR\)" "\# include \$\(INCLUDE_TOOLS_DIR\)"
    

    make compile
    make dist
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -r target/bin/x86_64-linux/ $out/bin
  '';

    
  vendorHash = lib.fakeHash;

  meta = {
    description = "New Relic Infrastructure Agent";
    homepage = "https://github.com/newrelic/infrastructure-agent.git";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davsanchez ];
    mainProgram = "newrelic-infra";
  };
}
