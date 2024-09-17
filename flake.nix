{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flox.url = "github:flox/flox/v1.3.0";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      flox,
    }:
    let
      platformM1 =
        { pkgs, ... }:
        {
          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          environment.systemPackages = [
            flox.packages.${pkgs.system}.default
          ];
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
      platformIntel = _: {

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;
        nixpkgs.hostPlatform = "aarch64-darwin";
        cromulent.services.podman.enabled = true;
      };

    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Jinxuan-MacBook-Pro
      darwinConfigurations."Jinxuan-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          ./common.nix
          platformIntel
        ];
      };

      darwinConfigurations."Jinxuan-MacBookM1-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          ./common.nix
          platformM1
          ./podman.nix
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."MacBook-Pro".pkgs;
    };
}
