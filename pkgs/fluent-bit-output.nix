{ 
  lib,
  pkgs,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  ... 
}:
let
  version = "2.1.0";

in
  buildGoModule rec {
    pname = "fluent-bit-output";
    inherit version;

    src = fetchzip {
      url = "https://github.com/newrelic/newrelic-fluent-bit-output/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-01SyjlHlt/yd1r3QU0J2siMHIX+30xoMeYZrDi8iQ90=";
    };

  vendorHash = null;

  ldflags = [
    "-w"
    "-s"
  ];

  buildInputs = [ stdenv pkgs.pcre pkgs.protobufc pkgs.cmake pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.go ];
  env.HOME = "$(pwd)";
  env.CGO_ENABLED = if stdenv.hostPlatform.isDarwin then "1" else "0";

  doCheck = false;

  # postInstall = ''
  #   mkdir -p $out
  #   cp -r ${build}/* $out/
  # '';

  meta = {
    description = "New Relic PHP Agent Daemon";
    mainProgram = "fluent-bit-output";
  };
}





