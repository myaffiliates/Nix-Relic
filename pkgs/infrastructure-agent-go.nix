{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "infrastructure-agent";
  version = "1.59.0";
  fbVersion = "2.1.0";
  
  fb =  builtins.fetchurl {
    url = "https://github.com/newrelic/newrelic-fluent-bit-output/releases/download/v${fbVersion}/out_newrelic-linux-amd64-${fbVersion}.so";
    sha256 = lib.fakeHash;
  };

  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "infrastructure-agent";
    rev = version;
    hash = "sha256-Kf7C4vJXjoJB+B695DQA3XWtm8IuBby8sKqH7F68Oy8=";
  };

  vendorHash = "sha256-0WLL15CXRi/flp4EV3Qt0wO1VaUmAokzsChpiqjs+YQ=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${version}"
    "-X main.gitCommit=${src.rev}"
  ];

  env.CGO_ENABLED = "0";

  excludedPackages = [
    "test/"
    "tools/"
  ];

  # subPackages = [
  #   "cmd/newrelic-infra"
  #   "cmd/newrelic-infra-ctl"
  #   "cmd/newrelic-infra-service"
  #   "internal/agent"
  #   "internal/instrumentation"
  #   "internal/integrations"
  #   "internal/plugins"
  # ];
   installPhase = ''
    curl -L --silent '${fb}' --output $out/fluent-bit-plugin/amd64/out_newrelic.so
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
