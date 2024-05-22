{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
  port = config.services.tailscale.port;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "management/ssh"
    ];

  system.stateVersion = "24.05";

  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    interfaceName = "userspace-networking";
    useRoutingFeatures = "both";
  };

  systemd.services.tailscaled.path = [ pkgs.iputils ];

  nixosContainer =
    {
      forwardPorts = [{ hostPort = port; containerPort = port; }];
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/tailscale:/var/lib/tailscale"
      ];
    };
}
