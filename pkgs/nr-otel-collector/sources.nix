{
  pkgs,
  stdenv,
  fetchFromGitHub,
  ocb,
}:
let
  distVersion = "0.8.3";
in
stdenv.mkDerivation {
  name = "collector-dist-${distVersion}";
  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "opentelemetry-collector-releases";
    rev = "nr-otel-collector-${distVersion}";
    hash = "sha256-CkjJMVDcOnfOI76VkEQetDDST85/32s1jayCYlCDdHI=";
  };
  nativeBuildInputs =
    (with pkgs; [
      gnumake
      go
    ])
    ++ [ ocb ];
  buildPhase = ''
    # script run by make needs the correct bash location
    patchShebangs ./scripts/build.sh

    export HOME=$TMPDIR
    chmod -R u+w .
    make generate-sources
  '';
  installPhase = ''
    # Remove log files as they make the build non-reproducible (contain dates)
    rm -rf distributions/nr-otel-collector/_build/build.log
    cp -r distributions/nr-otel-collector/_build/ $out
  '';
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-a8LhKZB5vRDNpRi94ZARG/ARdrsl4kcyda62BZ20nNg=";
}
