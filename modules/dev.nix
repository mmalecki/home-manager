{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
  gcloudWithComponents = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      kubectl
    ]
  );
in
{
  home.packages = with pkgs; [
    ripgrep
    rustup
    espup
    tree-sitter
    glow
    unstable.bun
    jq
    gcloudWithComponents
    tfenv
    gh
    feh
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      gsw = "git switch";
      gco = "git checkout";
    };

    shellAbbrs = {
      "g" = "git";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name  = "Maciej Małecki";
      email = "me@mmalecki.com";
    };
    settings.pull = {
      rebase = true;
    };
    settings.push = {
      autoSetupRemote = true;
    };
  };

  services.ssh-agent.enable = true;

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dev/dot/nvimsauce";

  home.sessionVariables = {
    EDITOR = "nvim";
    TFENV_CONFIG_DIR = "$HOME/.local/share/tfenv";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm/bin"
    "$HOME/bin"
    "$HOME/dev/dot/shellsauce/bin"
  ];
}
