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
  nginxVersion = "3.5.1";
  phpVersion = "11.5.0.18";
  mysqlVersion = "1.11.1";
  redisVersion = "1.12.0";

  mysql-sce = fetchzip {
    url = "https://github.com/newrelic/nri-mysql/releases/download/v${mysqlVersion}/nri-mysql_linux_${mysqlVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "0di7038i0pwpjipicmf7sfmbv28g7ns0svfayxgmw6z5ly60qa5q";
    #sha256 = "sha256-J4xl75ZkDkvnY87RQl8973CL1FASWqp3qilU/9xiamU=";
  };

  nginx-sce = fetchzip {
    url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/nri-nginx_linux_${nginxVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-2HONjnH0BSxu13gXsvoJoTF+aMt20r61CS4lDCAknx8=";
  };

  php-sce =  fetchzip {
    url = "https://download.newrelic.com/php_agent/archive/${phpVersion}/newrelic-php5-${phpVersion}-linux.tar.gz";
    sha256 = "1vxy3bk9pm57f9c4ipldz26104igj4fxammbazd23mwyym3prbjl";
    #sha256 = "sha256-ZPwVUUuhGHDT5owIlihzwcWeb5UX9NWr+43VrAdVYkU=";
  };

  redis-sce = fetchzip {
    url = "https://github.com/newrelic/nri-redis/releases/download/v${redisVersion}/nri-redis_linux_${redisVersion}_amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-RVJsqIAfDYBf5MtefWgbDrQA33kQad4TndTxz8Akoc8=";
  };

  fb =  builtins.fetchurl {
    url = "https://github.com/newrelic/newrelic-fluent-bit-output/releases/download/v${fbVersion}/out_newrelic-linux-amd64-${fbVersion}.so";
    sha256 = "0chy0w7aajb5mhxa6k1nbsgd2670xvsxj96wvchachf751ibdwzs";
    #sha256 = "0chy0w7aajb5mhxa6k1nbsgd2670xvsxj96wvchachf751ibdwzs";
  };

in

buildGoModule rec {
  pname = "infrastructure-agent";
  version = "1.60.0";

  src = fetchzip {
    url = "https://github.com/newrelic/infrastructure-agent/archive/refs/tags/${version}.tar.gz";
    sha256 = "0k494mwf4f56vqpfcidys508gbhx7dnbvxnjqp90nj2k4hhf9x7z";
    #sha256 = "sha256-Kf7C4vJXjoJB+B695DQA3XWtm8IuBby8sKqH7F68Oy8=";
    postFetch = ''
      export PATH="${pkgs.git}/bin:${pkgs.go}/bin:$PATH"
      cd $out
      go mod edit github.com/newrelic/go-agent/v3 v3.36.0
      go mod tidy
      go mod vendor
    '';  
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
    cp -r ${php-sce}/agent/x64/newrelic-*.so $out/lib/
    cp -r ${php-sce}/daemon/newrelic-daemon.x64 $out/bin/daemon
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

