{ pkgs, ... }:
{
  imports = [
    ../../modules/home/general-dev.nix
    ../../modules/home/vscode.nix
  ];

  m1cr0man.vscode.remoteEditor = true;
  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "25.05";
    username = "george";
    homeDirectory = "/home/george";
    packages = with pkgs; [
      openvscode-server
    ];
  };
}
