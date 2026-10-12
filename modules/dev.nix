{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
  gcloudWithComponents = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      kubectl
    ]
  );
in
{
  nixpkgs.config.allowUnfree = true;

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
    packer
    gh
    feh
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      gsw = "git switch";
      gco = "git checkout";
      gst = "git status";
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
    settings.rebase = {
      autostash = true;
    };
    settings.push = {
      autoSetupRemote = true;
    };
    settings.init = {
      defaultBranch = "latest";
    };
  };

  services.ssh-agent.enable = true;

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dev/dot/nvimsauce";

  home.sessionVariables = {
    EDITOR = "nvim";
    TFENV_CONFIG_DIR = "$HOME/.local/share/tfenv";

    DOCKERSAND_SSH = "1";
    DOCKERSAND_GCLOUD = "1";
    DOCKERSAND_GH = "1";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm/bin"
    "$HOME/bin"
    "$HOME/dev/dot/shellsauce/bin"
  ];
}
