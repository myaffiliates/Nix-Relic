{ 
  lib,
  pkgs,
  stdenv,
  system,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  ... 
}:
let
  version = "2.1.0";

  oldGo120 = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/0a25e2c87e784bf7e06e7833ec0e06d34836959a.tar.gz";
      sha256 = "sha256:0gp3rincm83m2b26dbyvr5dh4zk5i0cbva3lzbzd38k1c6mfyyws";
    }) {};

  go-version = oldGo120.go;

  

in
  buildGoModule rec {
    pname = "fluent-bit-output";
    inherit version go-version pkgs system;

    src = fetchzip {
      url = "https://github.com/newrelic/newrelic-fluent-bit-output/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-01SyjlHlt/yd1r3QU0J2siMHIX+30xoMeYZrDi8iQ90=";
    };

  vendorHash = null;

  ldflags = [
    "-w"
    "-s"
  ];

  buildInputs = [ stdenv pkgs.pcre pkgs.protobufc pkgs.cmake pkgs.gnumake pkgs.autoconf pkgs.gcc go-version ];
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





