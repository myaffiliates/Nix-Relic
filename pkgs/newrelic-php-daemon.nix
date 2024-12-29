{
  pkgs,
  buildGoModule,
  lib,
  fetchzip,
}:
let
  version = "11.4.0.17";
 
  # phpSource = fetchzip {
  #   url = "https://github.com/php/php-src/archive/refs/tags/php-8.2.27.tar.gz";
  #   sha256 = "";
  # };
 
  # phpSource = pkgs.fetchFromGitHub {
  #   owner = "php";
  #   repo = "php-src";
  #   rev = "php-8.2.27";
  #   sha256 = "sha256-UbS+4kBrc3ohSHyl0VyjeeS72ZDjLh8PIIylodZFYOE=";
  # };
in
{
newrelic-php-daemon = buildGoModule rec {
  pname = "newrelic-php-agent";
  inherit version;

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

  meta = {
    description = "New Relic PHP Agent";
    homepage = "https://github.com/newrelic/newrelic-php-agent";
  };
}