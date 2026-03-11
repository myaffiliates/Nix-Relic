# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  modifications = final: prev: {
    unstable.fluent-bit = prev.unstable.fluent-bit.overrideAttrs (attrs: {
      # NIX_CFLAGS_COMPILE = (attrs.NIX_CFLAGS_COMPILE or "") + "-FLB_OUT_NRLOGS=ON";
      cmakeFlags = attrs.cmakeFlags ++ [
        "-DFLB_OUT_NRLOGS=ON"
      ];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config = {
        permittedInsecurePackages = [ "openssl-1.1.1w" ];
        allowUnfree = true;
      };
    };
  };
}
