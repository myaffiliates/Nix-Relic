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
    sha256 = "02gfbrj3rwzvw4pgnic2xp11j3j7p4j0pnjy3lwzlg4x536izz8p";
  };

  nag-sce = fetchzip {
    url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/nri-nagios_linux_${nagVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "1grajwz0iypdhxkaadrrc115cya763qfas35d7fn24p7mdikx6ga";
  };

  nginx-sce = fetchzip {
    url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/nri-nginx_linux_${nginxVersion}_amd64.tar.gz";
    sha256 = "0y6dzwd8v9ypfvw0bfcr7g2237gfjkr6v27yiwd8yqdy40xfzpmw";
  };

  php-sce =  fetchzip {
    url = "https://download.newrelic.com/php_agent/release/newrelic-php5-${phpVersion}-linux.tar.gz";
    sha256 = "08l1wydfj7s09xn16k9xlgkp67ra21flgga9wd61iydy6r7j5s9a";
  };

  flex-sce = fetchzip {
    url = "https://github.com/newrelic/nri-flex/releases/download/v${flexVersion}/nri-flex_linux_${flexVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "01mzsqm52qiha6i0ycw589j0pwavzhha98klzd38jc1dgfv7h63n";
  };

  fb =  builtins.fetchurl {
    url = "https://github.com/newrelic/newrelic-fluent-bit-output/releases/download/v${fbVersion}/out_newrelic-linux-amd64-${fbVersion}.so";
    sha256 = "0chy0w7aajb5mhxa6k1nbsgd2670xvsxj96wvchachf751ibdwzs";
  };   

  fbParsers = builtins.fetchurl {
    url = "https://github.com/newrelic/fluent-bit-package/blob/main/parsers.conf";
    sha256 = "0nrb6mmzmv01wd83a8zmf03jrjml7xnwwjjs4j9w37qyqia7ynjc";
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

