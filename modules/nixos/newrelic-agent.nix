{
  lib,
  pkgs,
  config,
  ...
}:
{
environment.systemPackages = with pkgs; [
  newrelic-agent
];
}

