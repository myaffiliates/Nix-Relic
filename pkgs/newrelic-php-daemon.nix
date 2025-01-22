{ 
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  ... 
}:
let
  version = "11.5.0.18";

  ext-sce = fetchzip {
    url = "https://download.newrelic.com/php_agent/archive/${version}/newrelic-php5-${version}-linux.tar.gz";
    sha256 = "sha256-ZPwVUUuhGHDT5owIlihzwcWeb5UX9NWr+43VrAdVYkU=";
  };
in
  buildGoModule rec {
    pname = "newrelic-php-daemon";
    inherit version ext-sce;

    src = fetchzip {
      url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
    };

  vendorHash = "sha256-B5EJDzZlUMt70ndCe7anEQQ1inU7NQQ7m05E/mpCmT4=";

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
    cp -r ${php-sce}/agent/x64/newrelic-20220829.so $out/lib/ newrelic-php82.so
    cp -r ${php-sce}/agent/x64/newrelic-20230831.so $out/lib/ newrelic-php83.so
    cp -r ${php-sce}/agent/x64/newrelic-20240924.so $out/lib/ newrelic-php84.so
  '';

  meta = {
    description = "New Relic PHP Agent Daemon";
    mainProgram = "daemon";
  };
}
