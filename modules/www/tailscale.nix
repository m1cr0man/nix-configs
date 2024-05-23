{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
  };


  environment.systemPackages = [ pkgs.tailscale ];

  # Fix the ping command
  systemd.services.tailscaled.path = [ pkgs.iputils ];
}
