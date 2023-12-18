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

  systemd.user.services.openvscode-server = {
    Unit.Description = "Open VSCode Server";
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pkgs.openvscode-server}/bin/openvscode-server --telemetry-level=off --socket-path=/home/lucas/.openvscode-server.sock --accept-server-license-terms --without-connection-token";
      ExecSearchPath = [ "${pkgs.coreutils}/bin" "${pkgs.git}/bin" "${pkgs.gnused}/bin" "/home/lucas/.nix-profile/bin" "/nix/profile/bin" "/home/lucas/.local/state/nix/profile/bin" "/etc/profiles/per-user/lucas/bin" ];
    };
  };
}
