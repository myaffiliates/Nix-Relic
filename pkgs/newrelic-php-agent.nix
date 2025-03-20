{
  pkgs,
  stdenv,
  lib,
  fetchFromGitHub,
  fetchzip,
  pkg-config,
  pcre,
  ...
}:
let
  version = "11.7.0.21";
 
  phpSource = pkgs.fetchFromGitHub {
    owner = "php";
    repo = "php-src";
    rev = "php-8.2.28";
    sha256 = "sha256-UbS+4kBrc3ohSHyl0VyjeeS72ZDjLh8PIIylodZFYOE=";
  };
in

stdenv.mkDerivation rec {
  pname = "newrelic-php-agent";
  inherit phpSource version;

  src = fetchzip {
    url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
  };

  nativeBuildInputs = [ pkg-config pkgs.php82.unwrapped ];
  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.automake pkgs.libtool pkgs.git pkgs.bash pkgs.go phpSource ];

  env.NIX_CFLAGS_COMPILE = "-O2";

  buildPhase = ''
    export HOME=$(pwd)
    export GOPROXY="direct"

    substituteInPlace Makefile \
      --replace-quiet "/bin/bash" "${pkgs.bash}/bin/bash"
  
    substituteInPlace agent/php_includes.h \
      --replace-quiet "ext/pdo/php_pdo_driver.h" "${phpSource}/ext/pdo/php_pdo_driver.h"

    substituteInPlace daemon/Makefile \
      --replace-quiet "go" "${pkgs.go}/bin/go"

    make agent
  '';
  installPhase = ''
     mkdir -p $out/lib

     cp -r agent/.libs/newrelic.so $out/lib
  '';

  meta = {
    description = "New Relic PHP Agent";
    homepage = "https://github.com/newrelic/newrelic-php-agent";
    mainProgram = "newrelic-php-agent";
  };
}
