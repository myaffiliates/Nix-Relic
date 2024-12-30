{ pkgs, lib, buildGoModule, fetchFromGitHub }:

  buildGoModule rec {
    pname = "go-agent";
    version = "3.35.1";
    
  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "go-agent";
    rev =  "v${version}";
    hash = "sha256-5baGIv8K5U2qH9Ly4YDirVQsEV09aVdyGZ+ohiTO7oc=";
  };

  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.go ];

  vendorHash = lib.fakeHash;

  checkFlags = [ "-skip TestGenerateAndCompile" ];
  CGO_ENABLED = 0;

  sourceRoot = "${src.name}/v3/newrelic";
}
