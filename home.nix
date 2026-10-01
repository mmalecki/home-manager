{ config, pkgs, ... }:

let
  llama = builtins.getFlake "github:ggml-org/llama.cpp/v0.5.0";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "maciej";
  home.homeDirectory = "/home/maciej";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Developer tooling, etc.
    ripgrep
    rustup
    espup
    tree-sitter
    opencode
    glow

    # Desktop
    swayidle
    chromium
    kitty
    swaybg
    zathura
    remmina
    wl-clipboard
    wtype
    llama.packages.${pkgs.stdenv.hostPlatform.system}.rocm
  ];

  # Desktop environment setup
  programs.fuzzel.enable = true;
  programs.password-store.enable = true;
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
    };
  };
  programs.swaylock.enable = true;
  services.swayidle = 
  let
    lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
    display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
  in
  {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 600;
        command = display "off";
        resumeCommand = display "on";
      }
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
    };
  };
  services.polkit-gnome.enable = true;
  services.ssh-agent.enable = true;

  programs.fish = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name  = "Maciej Małecki";
      email = "me@mmalecki.com";
    };
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dev/dot/nvimsauce";

  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
  xdg.configFile."niri/bg.jpg".source = ./niri/bg.jpg;
  xdg.configFile."waybar/config.jsonc".source = ./niri/waybar.jsonc;

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Desktop background";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i %h/.config/niri/bg.jpg";
      Restart = "on-failure";
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/maciej/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = ["$HOME/.cargo/bin" "$HOME/bin" "$HOME/dev/dot/shellsauce/bin" ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
