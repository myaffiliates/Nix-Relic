{ 
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  ... 
}:
let
  version = "11.7.0.21";

  ext-sce = fetchzip {
    url = "https://download.newrelic.com/php_agent/archive/${version}/newrelic-php5-${version}-linux.tar.gz";
    sha256 = "sha256-LGkX9P98udbiCnjiBpW0DXQtyQaRMuWTtoSuHgUYpFA=";
  };
in
  buildGoModule rec {
    pname = "newrelic-php-daemon";
    inherit version ext-sce;

    src = fetchzip {
      url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-h5R2b8L1NT0KF4ZZXWb0d25ukARLRZ4KYSVN7weVUjw=";
    };

  vendorHash = "sha256-+PW0tu5iwudsqPR9tByOOLozT3WFXNgSlPWDY0e8e/U=";

  ldflags = [
    "-w"
    "-s"
    "-X main.version=${version}"
  ];

  env.CGO_ENABLED = if stdenv.hostPlatform.isDarwin then "1" else "0";
  
  sourceRoot = "${src.name}/daemon";

  doCheck = false;

  postInstall = ''
    mkdir -p $out/lib
    cp -r ${ext-sce}/agent/x64/newrelic-20220829.so $out/lib/newrelic-php82.so
    cp -r ${ext-sce}/agent/x64/newrelic-20230831.so $out/lib/newrelic-php83.so
    cp -r ${ext-sce}/agent/x64/newrelic-20240924.so $out/lib/newrelic-php84.so
  '';

  meta = {
    description = "New Relic PHP Agent Daemon";
    mainProgram = "daemon";
  };
}
