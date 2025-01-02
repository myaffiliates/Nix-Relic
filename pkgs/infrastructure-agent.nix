{
  pkgs,
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  pkg-config,
}: 
let 
  fbVersion = "2.1.0";
  nagVersion = "2.9.7";
  nginxVersion = "3.5.0";
  phpVersion = "11.4.0.17";
  flexVersion = "1.16.3";

  nag-sce = fetchzip {
    url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/nri-nagios_linux_${nagVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-99VcpXZuTg4PP193o1WV9Jl1FFr+Pm7iJgy0ygHhak8=";
  };

  nginx-sce = fetchzip {
    url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/nri-nginx_linux_${nginxVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-y1sNjQf8MPTUHWlRO4szk1jm4/Q/lXIKM7+aI4LcMQ0=";
  };

  php-sce =  fetchzip {
    url = "https://download.newrelic.com/php_agent/release/newrelic-php5-${phpVersion}-linux.tar.gz";
    sha256 = "sha256-acTNfszCcX6RKF+XY2yb4S/dahuyHoEWa11//ua6MaY=";

  };

  flex-sce = fetchzip {
    url = "https://github.com/newrelic/nri-flex/releases/download/v${flexVersion}/nri-flex_linux_${flexVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-GMB86hg6B3WB1C6x5JzdO7Uo0lf0iyBXNqqfE5sXP+Q=";
  };

  fb =  builtins.fetchurl {
    url = "https://github.com/newrelic/newrelic-fluent-bit-output/releases/download/v${fbVersion}/out_newrelic-linux-amd64-${fbVersion}.so";
    sha256 = "0chy0w7aajb5mhxa6k1nbsgd2670xvsxj96wvchachf751ibdwzs";
  };

  fbParsers = builtins.fetchurl {
    url = "https://github.com/newrelic/fluent-bit-package/blob/main/parsers.conf";
    sha256 = "1rgc61mwczn31rs33w8ha843z2ywdjqn9aiilxp5v8w4q4gqp4l3";
  };

in
#stdenv.mkDerivation rec {
buildGoModule rec {
  pname = "infrastructure-agent";
  version = "1.59.0";

  # src = fetchzip {
  #   url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/newrelic-infra_linux_${version}_amd64.tar.gz";
  #   sha256 = "sha256-K4woRT9CN7ZMyLInm1eaca2byMpYSNXcq7txLuKrYzM=";
  # };

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

  buildInputs = [ pkgs.curl ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/etc/newrelic-infra/logging.d
    mkdir -p $out/etc/newrelic-infra/integrations.d
    mkdir -p $out/lib
    mkdir -p $out/var/db/newrelic-infra/newrelic-integrations/logging
    mkdir -p $out/var/db/newrelic-infra/newrelic-integrations/bin

    # cp -r ${src}/usr/bin/* $out/bin
    cp -r ${nag-sce}/* $out/
    cp -r ${nginx-sce}/* $out/
    cp -r ${php-sce}/agent/x64/newrelic-20220829.so $out/lib/newrelic.so
    cp -r ${php-sce}/daemon/newrelic-daemon.x64 $out/bin/daemon
    cp -r ${flex-sce}/nri-flex $out/var/db/newrelic-infra/newrelic-integrations/bin
    curl -L --silent '${fb}' --output $out/var/db/newrelic-infra/newrelic-integrations/logging/out_newrelic.so
    curl -L --silent '${fbParsers}' --output $out/var/db/newrelic-infra/newrelic-integrations/logging/parsers.conf
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

