{ pkgs, ... }:
{
  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Some packages I want in every environment
  environment.systemPackages = with pkgs; [
    git
    htop
    screen
    vim
    wget
    zstd
    sops
    nix-prefetch-github
  ];

  # Fix vscode-server node binary on login
  environment.shellInit =
    let
      node = pkgs.nodejs-16_x;
      findutils = pkgs.findutils;
    in
    ''
      umask 0027
      if test -e ~/.vscode-server; then
        ${findutils}/bin/find ~/.vscode-server -type f -name node \( -execdir rm '{}' \; -and -execdir ln -s '${node}/bin/node' '{}' \; \)
      fi
    '';
}
