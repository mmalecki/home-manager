{ ... }:

{
  home.username = "maciej";
  home.homeDirectory = "/home/maciej";

  # This value determines the Home Manager release that your configuration is
  # compatible with. Do not change it without reading the release notes.
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
