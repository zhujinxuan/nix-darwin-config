{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [ pkgs.vim ];
        environment.shellAliases = { ll = "ls -l"; };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        nix.package = pkgs.nix;

        nix.settings = {
          # Necessary for using flakes on this system.
          experimental-features = "nix-command flakes";
          trusted-substituters = [
            "https://cache.nixos.org"
            "https://all-hies.cachix.org"
            "https://hercules-ci.cachix.org"
            "https://haskell-language-server.cachix.org"
            "https://emacs-osx.cachix.org"
            "https://srid.cachix.org"
            "https://nequissimus.cachix.org"
            "https://devenv.cachix.org"
          ];
        };

        # You can enable the following option to migrate to new style nixbld users
        nix.configureBuildUsers = true;

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true; # default shell on catalina

        services.skhd = {
          enable = true;
          skhdConfig = builtins.readFile ./skhdrc;
        };

        services.yabai = {
          enable = true;
          config = {
            mouse_follows_focus = "on";
            focus_follows_mouse = "off";
            window_placement = "second_child";
            window_topmost = "off";
            window_shadow = "on";
            window_opacity = "off";
            window_opacity_duration = 0.0;
            active_window_opacity = 1.0;
            normal_window_opacity = 0.9;
            window_border = "off";
            window_border_width = 6;
            active_window_border_color = "0xff775759";
            normal_window_border_color = "0xff555555";
            insert_feedback_color = "0xffd75f5f";
            split_ratio = 0.5;
            auto_balance = "off";
            mouse_modifier = "fn";
            mouse_action1 = "move";
            mouse_action2 = "resize";
            mouse_drop_action = "swap";
            layout = "bsp";
            top_padding = 0;
            bottom_padding = 0;
            left_padding = 0;
            right_padding = 0;
            window_gap = 6;
          };
        };

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # fonts
        fonts.fonts = [ pkgs.rubik pkgs.nerdfonts ];
        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "x86_64-darwin";
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MacBook-Pro
      darwinConfigurations."MacBook-Pro" =
        nix-darwin.lib.darwinSystem { modules = [ configuration ]; };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."MacBook-Pro".pkgs;
    };
}
