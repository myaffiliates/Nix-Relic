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
  phpVersion = "11.5.0.18";
  flexVersion = "1.16.3";
  mysqlVersion = "1.11.1";
  redisVersion = "1.12.0";

  mysql-sce = fetchzip {
    url = "https://github.com/newrelic/nri-mysql/releases/download/v${mysqlVersion}/nri-mysql_linux_${mysqlVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-J4xl75ZkDkvnY87RQl8973CL1FASWqp3qilU/9xiamU=";
  };

  nginx-sce = fetchzip {
    url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/nri-nginx_linux_${nginxVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-y1sNjQf8MPTUHWlRO4szk1jm4/Q/lXIKM7+aI4LcMQ0=";
  };

  php-sce =  fetchzip {
    url = "https://download.newrelic.com/php_agent/archive/newrelic-php5-${phpVersion}-linux.tar.gz";
    sha256 = "sha256-ZPwVUUuhGHDT5owIlihzwcWeb5UX9NWr+43VrAdVYkU=";
  };

  flex-sce = fetchzip {
    url = "https://github.com/newrelic/nri-flex/releases/download/v${flexVersion}/nri-flex_linux_${flexVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-GMB86hg6B3WB1C6x5JzdO7Uo0lf0iyBXNqqfE5sXP+Q=";
  };

  redis-sce = fetchzip {
    url = "https://github.com/newrelic/nri-redis/releases/download/v${redisVersion}/nri-redis_linux_${redisVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-RVJsqIAfDYBf5MtefWgbDrQA33kQad4TndTxz8Akoc8=";
  };

  fb =  builtins.fetchurl {
    url = "https://github.com/newrelic/newrelic-fluent-bit-output/releases/download/v${fbVersion}/out_newrelic-linux-amd64-${fbVersion}.so";
    sha256 = "0chy0w7aajb5mhxa6k1nbsgd2670xvsxj96wvchachf751ibdwzs";
  };

in

buildGoModule rec {
  pname = "infrastructure-agent";
  version = "1.59.1-A";

  src = fetchzip {
    url = "https://github.com/myaffiliates/infrastructure-agent/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-Kf7C4vJXjoJB+B695DQA3XWtm8IuBby8sKqH7F68Oy8=";
  };

  vendorHash = "sha256-0WLL15CXRi/flp4EV3Qt0wO1VaUmAokzsChpiqjs+YQ=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${version}"
  ];
  
  env.CGO_ENABLED = "0";
  
  # preBuild = ''
  #   export GOPROXY="direct"
  #   export PATH="${pkgs.git}/bin:$PATH"

  #   substituteInPlace go.sum \
  #     --replace-quiet 'v3.27.0 h1:Z3XB49d8FKjRcGzCyViCO9itBxiLPSpwjY1HlMvgamQ=' 'v3.35.1 h1:N43qBNDILmnwLDCSfnE1yy6adyoVEU95nAOtdUgG4vA=' \
  #     --replace-quiet 'v3.27.0/go.mod h1:TUzePinDc0BMH4Sui66rl4SBe6yOKJ5X/bRJekwuAtM=' 'v3.35.1/go.mod h1:GNTda53CohAhkgsc7/gqSsJhDZjj8vaky5u+vKz7wqM='

  #   substituteInPlace go.mod \
  #     --replace-quiet 'go-agent/v3 v3.27.0' 'go-agent/v3 v3.35.1'
  #   go mod vendor
  # '';

  subPackages = [
    "cmd/newrelic-infra"
    "cmd/newrelic-infra-ctl"
    "cmd/newrelic-infra-service"
  ];

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/etc/newrelic-infra/logging.d
    mkdir -p $out/etc/newrelic-infra/integrations.d
    mkdir -p $out/lib
    mkdir -p $out/var/db/newrelic-infra/newrelic-integrations/logging
    mkdir -p $out/var/db/newrelic-infra/newrelic-integrations/bin

    cp -r ${nginx-sce}/* $out/
    cp -r ${mysql-sce}/* $out/
    cp -r ${redis-sce}/* $out/
    cp -r ${php-sce}/agent/x64/newrelic-20220829.so $out/lib/newrelic.so
    cp -r ${php-sce}/daemon/newrelic-daemon.x64 $out/bin/daemon
    cp -r ${flex-sce}/nri-flex $out/var/db/newrelic-infra/newrelic-integrations/bin
    cp -r ${fb} $out/var/db/newrelic-infra/newrelic-integrations/logging/out_newrelic.so
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

