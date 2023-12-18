{ pkgs, ... }:
{
  imports = [
    ../../modules/home/general-dev.nix
    ../../modules/home/vscode.nix
  ];

  m1cr0man.vscode.remoteEditor = true;
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];
  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "24.05";
    username = "lucas";
    homeDirectory = "/home/lucas";
    packages = with pkgs; [
      openvscode-server
    ];
  };
}
