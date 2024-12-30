{ buildGoModule, lib, fetchzip }:

 buildGoModule rec {
  pname = "newrelic-php-agent";
  version = "11.4.0.17";

  src = fetchzip {
    url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
  };

  vendorHash = lib.fakeHash;

  sourceRoot = "${src.name}/daemon";
  
  installPhase = ''
     mkdir -p $out/bin

     cp -r newrelic-php-agent/bin $out/bin  
  '';
}
