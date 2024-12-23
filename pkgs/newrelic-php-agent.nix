{
  lib,
  stdenv,
  fetchzip
  #fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "newrelic-php-agent";
  version = "11.4.0.17";

  src = fetchzip {
    url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
    sha256 = "0xw6cr5jgi1ir13q6apvrivwmmpr5j8vbymp0x6ll0kcv6366hnn";
  };
}