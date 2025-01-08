{ 
  lib,
  stdenv,
  buildGoModule,
  fetchzip,
  ... 
}:
  buildGoModule rec {
    pname = "newrelic";
    version = "0.97.3";

    src = fetchzip {
      url = "https://github.com/newrelic/newrelic-cli/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-PUtqxOOkxnhkMr+XNGVe7CB4ybnZSTHkg/O3tcQ0TlM=";
    };

  vendorHash = lib.fakeHash;

  ldflags = [
    "-w"
    "-s"
    "-X main.version=${version}"
  ];

  env.CGO_ENABLED = "0";

  subPackages = [
    "cmd/newrelic"
  ];

  doCheck = false;

  meta = {
    description = "New Relic cli";
    mainProgram = "newrelic";
  };
}
