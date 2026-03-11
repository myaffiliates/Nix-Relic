{
  description = "Collection of infra observability tools packaged for Nix and accompanied by modules";

  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs =
    { self, nixpkgs, flake-utils, ... }:

    flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system};
    in {

      packages = import ./newrelic { inherit pkgs; };

      overlays = import ../overlays { inherit pkgs; };

    });
}
