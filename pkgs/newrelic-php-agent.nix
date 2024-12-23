{
  pkgs,
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  pcre2,
}:
let
  version = "11.4.0.17";

  myPhp = (pkgs.php82.buildEnv {
    extensions = ({ all, enabled, ... }: (lib.filter (e: e !=  pkgs.php82.extensions.openssl) enabled) ++ (with all; [ 
      openssl-legacy 
    ])); 
  });

in

stdenv.mkDerivation rec {
  pname = "newrelic-php-agent";
  inherit (myPhp.unwrapped) version;

  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "newrelic-php-agent";
    rev = "v${version}";
    sha256 = "GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
  };

  # internalDeps = [
  #   php.extensions.pgsql
  # ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcre2 myPhp ];

  installPhase = ''
     cp -r agent/.libs/newrelic.so $out/libs
     cp -r newrelic-php-agent/bin $out/bin  
  '';

}