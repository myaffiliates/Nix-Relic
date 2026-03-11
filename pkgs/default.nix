# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: rec {
#  fluent-bit-output = pkgs.callPackage ./fluent-bit-output.nix {};
  infra-agent = pkgs.callPackage ./infrastructure-agent.nix {};
  newrelic-cli = pkgs.callPackage ./newrelic-cli.nix {};
  newrelic-php-daemon = pkgs.callPackage ./newrelic-php-daemon.nix {};
}