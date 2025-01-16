{ pkgs, lib, stdenv, buildGoModule, fetchFromGitHub }:
let
sum = pkgs.writeTextFile {
  name = "go.sum";
  text = ''                                                                         
github.com/google/go-cmp v0.6.0 h1:ofyhxvXcZhMsU5ulbFiLKl/XBFqE1GSq7atu8tAmTRI=
github.com/google/go-cmp v0.6.0/go.mod h1:17dUlkBOakJ0+DkrSSNjCkIjxS6bF9zb3elmeNGIjoY=
golang.org/x/net v0.25.0 h1:d/OCCoBEUq33pjydKrGQhw7IlUPI2Oylr+8qLx49kac=
golang.org/x/net v0.25.0/go.mod h1:JkAGAh7GEvH74S6FOH42FLoXpXbE/aqXSrIQjXgsiwM=
golang.org/x/sys v0.20.0 h1:Od9JTbYCk261bKm4M/mw7AklTlFYIa0bIp9BgSm1S8Y=
golang.org/x/sys v0.20.0/go.mod h1:/VUhepiaJMQUp4+oa/7Zr1D23ma6VTLIYjOOTFZPUcA=
golang.org/x/text v0.15.0 h1:h1V/4gjBv8v9cjcR6+AR5+/cIYK5N/WAgiv4xlsEtAk=
golang.org/x/text v0.15.0/go.mod h1:18ZOQIKpY8NJVqYksKHtTdi31H5itFRjB5/qKTNYzSU=
google.golang.org/genproto/googleapis/rpc v0.0.0-20240528184218-531527333157 h1:Zy9XzmMEflZ/MAaA7vNcoebnRAld7FsPW1EeBB7V0m8=
google.golang.org/genproto/googleapis/rpc v0.0.0-20240528184218-531527333157/go.mod h1:EfXuqaE1J41VCDicxHzUDm+8rk+7ZdXzHV0IhO/I6s0=
google.golang.org/grpc v1.65.0 h1:bs/cUb4lp1G5iImFFd3u5ixQzweKizoZJAwBNLR42lc=
google.golang.org/grpc v1.65.0/go.mod h1:WgYC2ypjlB0EiQi6wdKixMqukr6lBc0Vo+oOgjrM5ZQ=
google.golang.org/protobuf v1.34.2 h1:6xV6lTsCfpGD21XK49h7MhtcApnLqkfYgPcdHftf6hg=
google.golang.org/protobuf v1.34.2/go.mod h1:qYOHts0dSfpeUzUFpOMr/WGzszTmLH+DiWniOlNbLDw=
  '';
};

in
  buildGoModule rec {
# stdenv.mkDerivation rec {
    pname = "go-agent";
    version = "3.35.1";
    inherit sum;

  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "go-agent";
    rev =  "v${version}";
    hash = "sha256-iqZhio2DZ7wPUEgtg14phqj1fstNwILWq1epedZ8XSg=";
    postFetch = ''
      export PATH="${pkgs.git}/bin:${pkgs.go}/bin:$PATH"
      export HOME=$(pwd)
      cd $out/v3
      go mod tidy
      go mod vendor
      # mkdir $out/v3/vendor
      # go mod download github.com/newrelic/go-agent/v3
      #github.com/newrelic/go-agent/v3/integrations/logcontext-v2/logWriter
      #go mod download github.com/newrelic/go-agent/v3/integrations/logcontext-v2/nrwriter      
      # cd $out/v3/integrations/logcontext-v2/logWriter
      # go mod tidy
      # cd $out/v3/integrations/logcontext-v2/nrwriter
      # go mod tidy
    '';
  };
  
  vendorHash = "sha256-FYuZQZH0wlshg3YIeyDtrpIv2wCTLseqQwdcFbdJf6Y=";

  sourceRoot = "${src.name}/v3/newrelic";

  buildInputs = [ stdenv pkgs.go pkgs.git ];

  # subPackages = [
  #   "newrelic"
  #   "integrations/logcontext-v2/logWriter"
  #   "integrations/logcontext-v2/nrmysql"
  # ];

  env.CGO_ENABLED = if stdenv.hostPlatform.isDarwin then "1" else "0";
  env.HOME = "$(pwd)";
  env.GOPROXY = "direct";

  checkFlags = [ "-skip TestGenerateAndCompile" ];

  doCheck = false;

}
