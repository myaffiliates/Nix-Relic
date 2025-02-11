{ 
  lib,
  system ? builtins.currentSystem,  
  pkgs ? import <nixpkgs> { inherit system; },
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  ... 
}:
with pkgs;
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
    inherit version go-version system;

    src = fetchzip {
      url = "https://github.com/newrelic/newrelic-fluent-bit-output/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-CZD/+vVWwZoPuhmh0FY9fzzhd9M3xZKTEQcozu4Hpe0=";
      postFetch = ''
        cd $out
        chmod -R 777 .
        #go mod tidy
        #go mod vendor
      '';
    };


  vendorHash = null;

  ldflags = [
    "-w"
    "-s"
  ];

  buildInputs = [ stdenv pkgs.pcre pkgs.protobufc pkgs.cmake pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.go ];
  env.HOME = "$(pwd)";

  buildPhase = ''
    make linux/amd64
  '';

  doCheck = false;


  postInstall = ''
    mkdir -p $out
    cp -r /build/* $out/
  '';

  meta = {
    description = "New Relic PHP Agent Daemon";
    mainProgram = "fluent-bit-output";
  };
}





