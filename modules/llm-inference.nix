{ config, lib, pkgs, ... }:

let
  cfg = config.my.llmInference;
  llama = builtins.getFlake "github:ggml-org/llama.cpp/v0.5.0";
in
{
  options.my.llmInference.enable = lib.mkEnableOption "llama.cpp ROCm build";

  config = lib.mkIf cfg.enable {
    home.packages = [
      llama.packages.${pkgs.stdenv.hostPlatform.system}.rocm
    ];
  };
}
