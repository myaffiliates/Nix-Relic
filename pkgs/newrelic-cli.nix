{
  lib,
  buildGoModule,
  fetchzip,
  ...
}:
buildGoModule rec {
  pname = "newrelic";
  version = "0.106.23";

  src = fetchzip {
    url = "https://github.com/newrelic/newrelic-cli/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-9V/GP/ISsgiRewXckXdjHOLlDvEy9MTCb/wo5RDX7NY=";
  };

  vendorHash = "sha256-0URuEsGxxP0Toy8ek1KUrrzhcbFJc4qbSssS2XnIBuc=";

  ldflags = [
    "-w"
    "-s"
    "-X main.version=${version}"
  ];

  subPackages = [
    "cmd/newrelic"
  ];

  doCheck = false;

  meta = {
    description = "New Relic cli";
    mainProgram = "newrelic";
  };
}
