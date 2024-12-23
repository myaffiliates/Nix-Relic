{
  lib,
  stdenv,
  #fetchzip,
  fetchFromGitHub,
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

  # src = fetchzip {
  #   url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
  #   sha256 = "0xw6cr5jgi1ir13q6apvrivwmmpr5j8vbymp0x6ll0kcv6366hnn";
  # };
}