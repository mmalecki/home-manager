{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop;
in
{
  options.my.desktop.enable = lib.mkEnableOption "niri desktop environment";

  options.my.desktop.modKey = lib.mkOption {
    type = lib.types.str;
    default = "Super";
    example = "Alt";
    description = "niri's Mod key; set to Alt in VMs where the host grabs Super.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swayidle
      chromium
      kitty
      swaybg
      zathura
      remmina
      wl-clipboard
      wtype
      imagemagick
      xournalpp
      gimp
      feh
      f3d
      darktable
      prusa-slicer
    ];

    programs.fuzzel.enable = true;
    home.pointerCursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      gtk.enable = true;
    };
    programs.password-store.enable = true;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
    programs.swaylock.enable = true;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };

    services.swayidle =
    let
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
    in
    {
      enable = true;
      # swayidle's -w waits until swaylock has secured the session and daemonized
      # before releasing the sleep inhibitor, including lid/menu suspends.
      events.before-sleep = lock;
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
      settings.default-timeout = 5000;
    };
    services.polkit-gnome.enable = true;

    xdg.configFile."niri/config.kdl".text = builtins.replaceStrings
      [ "mod-key \"Super\"" ]
      [ "mod-key \"${cfg.modKey}\"" ]
      (builtins.readFile ./desktop/config.kdl);
    xdg.configFile."niri/bg.jpg".source = ./desktop/bg.jpg;
    xdg.configFile."waybar/config.jsonc".source = ./desktop/waybar.jsonc;
    xdg.configFile."waybar/power_menu.xml".source = ./desktop/power_menu.xml;

    systemd.user.services.swaybg = {
      Unit = {
        Description = "Desktop background";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i %h/.config/niri/bg.jpg";
        Restart = "on-failure";
      };
    };
  };
}
