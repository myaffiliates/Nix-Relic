{ pkgs, lib, stdenv, buildGoModule, fetchFromGitHub }:

  buildGoModule rec {
    pname = "go-agent";
    version = "3.35.1";
    
  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "go-agent";
    rev =  "v${version}";
    hash = "sha256-5baGIv8K5U2qH9Ly4YDirVQsEV09aVdyGZ+ohiTO7oc=";
  };

  vendorHash = lib.fakeHash;

  sourceRoot = "${src.name}/v3/newrelic";

  subPackages = [
    "v3/newrelic"
  ];
  
  env.CGO_ENABLED = if stdenv.hostPlatform.isDarwin then "1" else "0";

  checkFlags = [ "-skip TestGenerateAndCompile" ];

  doCheck = false;

}
