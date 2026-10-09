{ config, lib, pkgs, ... }:

let
  cfg = config.my.llmInference;
  llama = builtins.getFlake "github:ggml-org/llama.cpp/v0.6.0";
in
{
  options.my.llmInference.enable = lib.mkEnableOption "llama.cpp + SD build";

  config = lib.mkIf cfg.enable {
    home.packages = [
      llama.packages.${pkgs.stdenv.hostPlatform.system}.vulkan
      pkgs.stable-diffusion-cpp-vulkan
    ];
  };
}
