{ pkgs, ... }:
{
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
    rsync
  ];
}
