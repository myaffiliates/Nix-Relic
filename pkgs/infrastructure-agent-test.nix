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
  version = "1.59.2";
 
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
    url = "https://download.newrelic.com/php_agent/archive/${phpVersion}/newrelic-php5-${phpVersion}-linux.tar.gz";
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
stdenv.mkDerivation rec {
  # buildGoModule rec {
    pname = "infrastructure-agent";
    inherit version;
  
  # src = fetchFromGitHub {
  #   owner = "newrelic";
  #   repo = "infrastructure-agent";
  #   rev = version;
  #   hash = "sha256-IfPiexh6vPOFkMz1OqNouozKJoKXeQMYYhaPg/tU0sg=";
  
   src = fetchzip {
    url = "https://github.com/myaffiliates/infrastructure-agent/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-Kf7C4vJXjoJB+B695DQA3XWtm8IuBby8sKqH7F68Oy8=";
    postFetch = ''
      export HOME=$(pwd)
      export GOPROXY="direct"
      export PATH="${pkgs.git}/bin:${pkgs.go}/bin:$PATH"

      go get -u
      go mod tidy
    '';    
  };

  # vendorHash = "sha256-1acOfcjIvFG9pbkSktFQ4AypymvSphHZ5gvkvmkIkU8=";
  #vendorHash = "sha256-Mi6X5sENfKBjCbG/M0WxpCYTPhF6xAJ2WyXs8S7SIv8=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.cmake pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.automake pkgs.libtool pkgs.git pkgs.bash pkgs.go ];

  env.NIX_CFLAGS_COMPILE = "-O2";
  env_GO_BIN_PATH = "${pkgs.go}/bin/go";

  modPostBuild = ''
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
    cp -r ${flex-sce}/nri-flex $out/var/db/newrelic-infra/newrelic-integrations/bin
    cp -r ${fb} $out/var/db/newrelic-infra/newrelic-integrations/logging/out_newrelic.so
  '';

  # installPhase = ''
  #    cp -r target/* $out/
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
