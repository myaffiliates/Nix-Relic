{
  description = "Collection of infra observability tools packaged for Nix and accompanied by modules";

  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs =
    { self, nixpkgs, flake-utils, ... }@inputs:

    # let
    #   # # Supported systems for flake packages, shell, etc.
    #   # systems = [
    #   #   "aarch64-linux"
    #   #   "i686-linux"
    #   #   "x86_64-linux"
    #   #   "aarch64-darwin"
    #   #   "x86_64-darwin"
    #   # ];
    #   # # This is a function that generates an attribute by calling a function you
    #   # # pass to it, with each system as an argument
    #   # forAllSystems = nixpkgs.lib.genAttrs systems;


    # in
    # {
    flake-utils.lib.eachDefaultSystem (system: 
    let pkgs = nixpkgs.legacyPackages.${system}; in
    {
      packages = import ./pkgs;#  { pkgs = nixpkgs.legacyPackages.${system}; };
    
      nixosModules = import ./modules/nixos;

      darwinModules = import ./modules/darwin;

      overlays = import ./overlays { inherit inputs; };

      system = builtins.currentSystem;
           
    });
  

