{
  pkgs,
  stdenv,
  lib,
  #fetchFromGitHub,
  fetchzip,
  pkg-config,
  pcre,
}:
let
  version = "11.4.0.17";

  # myPhp = (pkgs.php82.unwrapped.dev.buildEnv {
  #   extensions = { enabled, all }: enabled ++ (with all; [ yaml ]); 
  # });

in

stdenv.mkDerivation rec {
  pname = "newrelic-php-agent";
  inherit version;

  src = fetchzip {
    url = "https://github.com/newrelic/newrelic-php-agent/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
    #sha256 = "0xw6cr5jgi1ir13q6apvrivwmmpr5j8vbymp0x6ll0kcv6366hnn";
  };

  # src = fetchFromGitHub {
  #   owner = "newrelic";
  #   repo = "newrelic-php-agent";
  #   rev = "v${version}";
  #   sha256 = "GOtjX8Oa6gkD28sFVsoVjI537MpABIAInNHJGjsul7U=";
  # };

  # internalDeps = [
  #   php.extensions.pgsql
  # ];

  nativeBuildInputs = [ pkg-config pkgs.php82.unwrapped ];
  buildInputs = [ pkgs.pcre pkgs.protobufc pkgs.gnumake pkgs.autoconf pkgs.gcc pkgs.automake pkgs.libtool pkgs.git ];

  env.NIX_CFLAGS_COMPILE = "-O2";

  installPhase = ''
     cp -r agent/.libs/newrelic.so $out/libs
     cp -r newrelic-php-agent/bin $out/bin  
  '';

}