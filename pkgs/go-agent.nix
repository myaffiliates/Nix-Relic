{ lib, buildGoModule, fetchFromGitHub }:

  buildGoModule rec {
    pname = "go-agent";
    version = "3.35.1";
    
  fetch = {
    type = "git";
    url = "https://github.com/newrelic/go-agent";
    rev =  "v${version}";
    sha256 = "1zbp1cqhxp0sz3faymam6h1f91r1gl8dnnjx7qg8r06bd5fbzllb";
  };

  vendorHash = lib.fakeHash;

  sourceRoot = "${src.name}/v3";
}
