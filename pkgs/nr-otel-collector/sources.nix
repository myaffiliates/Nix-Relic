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
    hash = "sha256-tUuNqaI92M2JVTI5Y5tEAe0ocPlNGxt+9v5Y84pGnrs=";
#    hash = "sha256-CkjJMVDcOnfOI76VkEQetDDST85/32s1jayCYlCDdHI="; 0.8.5
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
  outputHash = "sha256-C53rqfUDPtwJoOULkynCthT9p9baHylWXHw1LqY4J9g=";
  #"sha256-a8LhKZB5vRDNpRi94ZARG/ARdrsl4kcyda62BZ20nNg="; 0.8.5
}
