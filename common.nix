{ pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.vim ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  nix.settings = {
    # Necessary for using flakes on this system.
    experimental-features = "nix-command flakes";
    trusted-substituters = [
      "https://cache.nixos.org"
      "https://devenv.cachix.org"
      "https://cache.flox.dev"
    ];

    trusted-public-keys = [
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = true;
    interval = {
      Day = 7;
    };
    options = "--delete-older-than 1w";
  };

  # You can enable the following option to migrate to new style nixbld users
  nix.configureBuildUsers = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

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

  # fonts
  fonts.packages = with pkgs; [
    rubik
    nerdfonts
    fira-code
    fira-code-symbols
    emacs-all-the-icons-fonts
  ];
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
