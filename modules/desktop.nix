{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop;
in
{
  options.my.desktop.enable = lib.mkEnableOption "niri desktop environment";

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
    ];

    programs.fuzzel.enable = true;
    programs.password-store.enable = true;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
    programs.swaylock.enable = true;

    services.swayidle =
    let
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
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
      settings.default-timeout = 5000;
    };
    services.polkit-gnome.enable = true;

    xdg.configFile."niri/config.kdl".source = ../niri/config.kdl;
    xdg.configFile."niri/bg.jpg".source = ../niri/bg.jpg;
    xdg.configFile."waybar/config.jsonc".source = ../niri/waybar.jsonc;

    systemd.user.services.swaybg = {
      Unit.Description = "Desktop background";
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i %h/.config/niri/bg.jpg";
        Restart = "on-failure";
      };
    };
  };
}
