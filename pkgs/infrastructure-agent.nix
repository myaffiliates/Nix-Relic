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

stdenv.mkDerivation rec {
  pname = "infrastructure-agent";
  version = "1.59.0";
  fbVersion = "2.1.0";
  nagVersion = "2.9.7";
  nginxVersion = "3.5.0";
  phpVersion = "11.4.0.17";
  flexVersion = "1.16.3";

  src = fetchzip {
    url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/newrelic-infra_linux_${version}_amd64.tar.gz";
    sha256 = "sha256-K4woRT9CN7ZMyLInm1eaca2byMpYSNXcq7txLuKrYzM=";
  };

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
    sha256 = "08l1wydfj7s09xn16k9xlgkp67ra21flgga9wd61iydy6r7j5s9a";

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

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/etc/newrelic-infra/logging.d
    mkdir -p $out/lib
    mkdir -p $out/var/db/newrelic-infra/newrelic-integrations/logging

    cp -r ${src}/newrelic-infra/usr/bin $out/
    cp -r ${nag-sce}/* $out/
    cp -r ${nginx-sce}/* $out/
    cp -r ${php-sce}/agent/x64/newrelic-20220829.so $out/lib/newrelic.so
    cp -r ${php-sce}/daemon/newrelic-daemon.x64 $out/bin/daemon
    cp -r ${flex-sce}/nri-flex $out/var/db/newrelic-infra/newrelic-integrations/bin
    curl -L --silent '${fb}' --output $out/var/db/newrelic-infra/newrelic-integrations/logging/out_newrelic.so
    curl -L --silent '${fbParsers}' --output $out/var/db/newrelic-infra/newrelic-integrations/logging/parsers.conf
  '';
  
  meta = {
    description = "New Relic Infrastructure Agent";
    homepage = "https://github.com/newrelic/infrastructure-agent.git";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davsanchez ];
    mainProgram = "newrelic-infra";
  };
}

