{
  lib,
  stdenv,
  fetchFromGitHub,
  php,
  pkg-config,
  protobuf-c,
  pcre2,
}:
let
  version = "11.4.0.17";
in

stdenv.mkDerivation {
  pname = "newrelic-php-agent";
  inherit version;

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
  buildInputs = [ pcre2 protobuf-c php ];

  installPhase = ''
     cp -r agent/.libs/newrelic.so $out
     cp -r newrelic-php-agent/bin $out  
  '';

}