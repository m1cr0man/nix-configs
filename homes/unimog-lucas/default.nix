{ pkgs, ... }:
{
  imports = [
    ../../modules/home/general-dev.nix
    ../../modules/home/vscode.nix
  ];

  m1cr0man.vscode.remoteEditor = true;

  home = {
    stateVersion = "23.05";
    username = "lucas";
    homeDirectory = "/home/lucas";
    packages = with pkgs; [
      openvscode-server
    ];
  };
}
