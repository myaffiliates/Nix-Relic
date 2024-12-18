{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
}:
let
  distVersion = "11.4.0.17";
in
stdenv.mkDerivation {
  name = "newrelic-php-agent";
  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "newrelic-php-agent";
    rev = "v${distVersion}";
    hash = lib.fakeHash;
  };
  nativeBuildInputs =
    (with pkgs; [
      gnumake
    ]);
  buildPhase = ''
    # script run by make needs the correct bash location
    # patchShebangs ./scripts/build.sh

    export HOME=$TMPDIR
    chmod -R u+w .
    make
  '';
  installPhase = ''
    # Remove log files as they make the build non-reproducible (contain dates)
    #rm -rf distributions/nr-otel-collector/_build/build.log
    cp -r agent/.libs/newrelic.so $out
    cp -r newrelic-php-agent/bin $out
  '';
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-=";
}