{
  lib,
  stdenv,
  buildGoModule,
  fetchzip,
  ...
}:
let
version = "12.5.0.30";

ext-sce = fetchzip {
  url = "https://download.newrelic.com/php_agent/archive/${version}/newrelic-php5-${version}-linux.tar.gz";
  sha256 = "sha256-E8UtbSOxKsmIzKDqUWWHSP9jUWLu4T5zmzrK8NtSpTI=";
};
in

buildGoModule rec {
  pname = "newrelic-php-daemon";
  inherit version ext-sce;

  src = fetchzip {
    url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-b34QjGetqraEeaTpS5srKQ53iigOf9B69R+j5+MTTZs=";
  };

  vendorHash = "sha256-Y7YbcQzIAbe9kxJrdCaMN3GxjfNvqbnZ3iKuLioLjEY=";

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
    cp -r ${ext-sce}/agent/x64/newrelic-20220829.so $out/lib/newrelic-php82.x86_64-linux.so
    cp -r ${ext-sce}/agent/x64/newrelic-20230831.so $out/lib/newrelic-php83.x86_64-linux.so
    cp -r ${ext-sce}/agent/x64/newrelic-20240924.so $out/lib/newrelic-php84.x86_64-linux.so
    cp -r ${ext-sce}/agent/aarch64/newrelic-20220829.so $out/lib/newrelic-php82.aarch64-linux.so
    cp -r ${ext-sce}/agent/aarch64/newrelic-20230831.so $out/lib/newrelic-php83.aarch64-linux.so
    cp -r ${ext-sce}/agent/aarch64/newrelic-20240924.so $out/lib/newrelic-php84.aarch64-linux.so
  '';

  meta = {
    description = "New Relic PHP Agent Daemon";
    mainProgram = "daemon";
  };
}
