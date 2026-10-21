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
    stateVersion = "25.11";
    username = "lucas";
    homeDirectory = "/home/lucas";
    packages = with pkgs; [
      openvscode-server
    ];
  };

  services.syncthing = {
    enable = true;
    extraOptions = [
      "--gui-address=0.0.0.0:8384"
    ];
  };

  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;
    enableMcpIntegration = true;
  };

  programs.mcp.servers.context7 = {
    url = "https://mcp.context7.com/mcp";
    headers.CONTEXT7_API_KEY = "{file:/home/lucas/.context7.apikey}";
  };
}
