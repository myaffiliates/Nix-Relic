{ 
  lib,
  stdenv,
  buildGoModule,
  fetchzip,
  ... 
}:
  buildGoModule rec {
    pname = "newrelic";
    version = "0.97.7";

    src = fetchzip {
      url = "https://github.com/newrelic/newrelic-cli/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-7NlSbAzh8j7Y61jB84Mg1EDPdg6xSZrzywfaaWB/grI=";
    };

  vendorHash = "sha256-Uag2fN4M4vRxSEa3nRyvou88bBGrGCNIS3ofxXL+EMY=";

  ldflags = [
    "-w"
    "-s"
    "-X main.version=${version}"
  ];

  # env.CGO_ENABLED = "0";

  subPackages = [
    "cmd/newrelic"
  ];

  doCheck = false;

  meta = {
    description = "New Relic cli";
    mainProgram = "newrelic";
  };
}
