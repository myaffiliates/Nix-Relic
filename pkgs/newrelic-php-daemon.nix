{ 
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  ... 
}:
  buildGoModule rec {
    pname = "newrelic-php-daemon";
    version = "11.4.0.17";

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

  subPackages = [ "." ];

  sourceRoot = "${src.name}/daemon";

  meta = {
    description = "New Relic PHP Agent Daemon";
    mainProgram = "daemon";
  };
}
