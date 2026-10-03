{ ... }:

{
  imports = [
    ./modules/base.nix
    ./modules/dev.nix
    ./modules/desktop.nix
    ./modules/llm-inference.nix
  ];

  # Per-machine switches. On a box without these, drop the lines
  # (or set them to false).
  my.desktop.enable = true;
  my.llmInference.enable = true;
}
