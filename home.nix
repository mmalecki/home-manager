{ ... }:

{
  imports = [
    ./modules/base.nix
    ./modules/dev.nix
    ./modules/desktop.nix
  ];

  # Per-machine switches. On a desktop-less box, drop these two lines
  # (or set them to false).
  my.desktop.enable = true;
  my.desktop.llama.enable = true;
}
