{  pkgs, lib, buildGoModule, fetchzip, ... }:
let
  docker_Version = "2.6.8";
  flex_Version = "1.17.4";  
  fluent_bit_version = "3.4.0";
  nginx_Version = "3.6.5";
  mysql_Version = "1.18.4";
  redis_Version = "1.12.8";

docker_src = fetchzip {
  url = "https://github.com/newrelic/nri-docker/releases/download/v${docker_Version}/nri-docker_linux_${docker_Version}_${pkgs.go.GOARCH}.tar.gz";
  stripRoot = false;
  sha256 = if pkgs.go.GOARCH == "amd64" then
    "sha256-V5Dn1JqS1tuLxhQTWQw7iQR0qRuxLoD34aokaWlKNNM="
    else
    "sha256-knFISojK/NtkmIGDGT9sWWUi2MS99VCkMsYOsxA1sCk=";
};

flex_src = fetchzip {
  url = "https://github.com/newrelic/nri-flex/releases/download/v${flex_Version}/nri-flex_linux_${flex_Version}_${pkgs.go.GOARCH}.tar.gz";
  stripRoot = false;
  sha256 = if pkgs.go.GOARCH == "amd64" then
    "sha256-Tsnyr4fyhvBODDDZAb9w7iPr50ELKWTlM125vsNpVVM="
    else
    "sha256-pTwzy/46jVmSJW6FHUJAiLZzz3wlZxdNIBJ3+93O4N0=";
};

fluent-bit_src = builtins.fetchurl {
  url = "https://github.com/newrelic/newrelic-fluent-bit-output/releases/download/v${fluent_bit_version}/out_newrelic-linux-${pkgs.go.GOARCH}-${fluent_bit_version}.so";
  sha256 = if pkgs.go.GOARCH == "amd64" then
    "sha256:0n2dx889jk3pivxqnz2664q5ff6aqw1vrw4j8w6p31k5cz7h9ml0"
    else
    "sha256:033nfbydd4pvl7j8nkim3rl45l0p3qcqn1jq5fhnjifdxxi3s7yw";
};

mysql_src = fetchzip {
  url = "https://github.com/newrelic/nri-mysql/releases/download/v${mysql_Version}/nri-mysql_linux_${mysql_Version}_${pkgs.go.GOARCH}.tar.gz";
  stripRoot = false;
  sha256 = if pkgs.go.GOARCH == "amd64" then
    "sha256-emJ5DfLChKktQ2B5EeG5EWc2417hsHnudsH/PUHFNEc="
    else
    "sha256-BSe08XyXq5OGxUhWOf6PTdBx726Y8j5C3GCIf6xukfM=";
};

nginx_src = fetchzip {
  url = "https://download.newrelic.com/infrastructure_agent/binaries/linux/${pkgs.go.GOARCH}/nri-nginx_linux_${nginx_Version}_${pkgs.go.GOARCH}.tar.gz";
  stripRoot = false;
  sha256 = if pkgs.go.GOARCH == "amd64" then
    "sha256-3LtelEUNs3WjDFj+sHYCpNJDcjCp0Gf1al3Vr16phgg="
    else
    "sha256-0b1kG669yiTpWviVo8/IQ98xYMEZ4zM+Q5rLo7EmsFs=";
};

redis_src = fetchzip {
  url = "https://github.com/newrelic/nri-redis/releases/download/v${redis_Version}/nri-redis_linux_${redis_Version}_${pkgs.go.GOARCH}.tar.gz";
  stripRoot = false;
  sha256 = if pkgs.go.GOARCH == "amd64" then
    "sha256-9AUpkXOU6MKuZ5GcHCdFSkZaDL/pcR5mSNuiSAtS33c="
    else
    "sha256-b0+9skQYC5y5MBoPaACa0JE+pZEiAtJR2D9HA8ezZx4=";
};

in
buildGoModule rec {
  pname = "infrastructure-agent";
  version = "1.72.4";

  src = fetchzip {
    url = "https://github.com/newrelic/infrastructure-agent/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-u5Bd7PD5f180SVWBawtKnCg/tpdYtuEc0pVrogqxEXI=";
    postFetch = ''
      export HOME=$PWD
      export PATH="${pkgs.git}/bin:${pkgs.go}/bin:$PATH"
      cd $out
      go mod tidy
      go mod vendor
    '';
  };

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

    cp -r ${flex_src}/nri-flex $out/var/db/newrelic-infra/newrelic-integrations/bin/
    cp -r ${fluent-bit_src} $out/var/db/newrelic-infra/newrelic-integrations/logging/out_newrelic.so
    cp -r ${docker_src}/* $out/
    cp -r ${mysql_src}/* $out/
    cp -r ${nginx_src}/* $out/
    cp -r ${redis_src}/* $out/
  '';

  vendorHash = null;

  ldflags = [
    "-w"
    "-s"
    "-X main.version=${version}"
  ];

  doCheck = false;

  meta = {
    inherit version;
    description = "New Relic Infrastructure Agent";
    homepage = "https://github.com/newrelic/infrastructure-agent/archive/refs/tags/${version}.tar.gz";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "infrastructure-agent";
  };
}
