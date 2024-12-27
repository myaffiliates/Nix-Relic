{
  pkgs,
  stdenv,
  lib,
  #fetchFromGitHub,
  fetchzip,
  pkg-config,
  pcre,
}:
let
  version = "11.4.0.17";

  php-src = fetchzip {
    url = "https://github.com/php/php-src/archive/refs/tags/php-8.2.27.tar.gz";
    sha256 = "sha256-GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
  };

in

stdenv.mkDerivation rec {
  pname = "newrelic-php-agent";
  inherit php-src version;

  src = fetchzip {
    url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
  };

  nativeBuildInputs = [ pkg-config pkgs.php82.unwrapped php-src ];
  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.automake pkgs.libtool pkgs.git ];

  env.NIX_CFLAGS_COMPILE = "-O2";

  buildPhase = ''
    substituteInPlace agent/php_includes.h \
      --replace "ext/pdo/php_pdo_driver.h" "${php-src}/ext/pdo/php_pdo_driver.h"
  '';
  
#include "ext/standard/info.h"

  installPhase = ''
     cp -r agent/.libs/newrelic.so $out/libs
     cp -r newrelic-php-agent/bin $out/bin  
  '';

  meta = {
    description = "New Relic PHP Agent";
    homepage = "https://github.com/newrelic/newrelic-php-agent";
  };
}