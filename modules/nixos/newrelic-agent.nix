{
  lib,
  pkgs,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [ newrelic-php-agent newrelic-php-daemon ];
}

