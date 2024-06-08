{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.tailscaled.path = [ pkgs.iputils ];
}
