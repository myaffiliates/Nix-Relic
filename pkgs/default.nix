# You can build the below packages using 'nix build .#example'
{pkgs}: rec {
  fluent-bit-output = pkgs.callPackage ./fluent-bit-output.nix {};
  go-agent = pkgs.callPackage ./go-agent.nix {};
  infrastructure-agent = pkgs.callPackage ./infrastructure-agent.nix {};
  newrelic-cli = pkgs.callPackage ./newrelic-cli.nix {};
  newrelic-php-agent = pkgs.callPackage ./newrelic-php-agent.nix {};
  newrelic-php-daemon = pkgs.callPackage ./newrelic-php-daemon.nix {};
  ocb = pkgs.callPackage ./ocb.nix {};
  test-agent = pkgs.callPackage ./infrastructure-agent-test.nix {}; 

  nr-otel-collector = pkgs.callPackage ./nr-otel-collector {
    # nr-otel-collector needs a specific version of ocb at this moment, hence this hack
    ocb = let
      version = "0.108.0";
      src = pkgs.fetchFromGitHub {
        owner = "open-telemetry";
        repo = "opentelemetry-collector";
        rev = "cmd/builder/v${version}";
        hash = "sha256-Ucp00OjyPtHA6so/NOzTLtPSuhXwz6A2708w2WIZb/E=";
        fetchSubmodules = true;
      };
    in
      # For why this was needed, see
      # https://discourse.nixos.org/t/inconsistent-vendoring-in-buildgomodule-when-overriding-source/9225/6
      ocb.override rec {
        buildGoModule = args:
          pkgs.buildGoModule (args
            // {
              inherit src version;
              vendorHash = "sha256-MTwD9xkrq3EudppLSoONgcPCBWlbSmaODLH9NtYgVOk=";
            });
      };
  };
}
