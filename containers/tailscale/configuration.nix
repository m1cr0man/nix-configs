{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "monitoring/client"
      "management/ssh"
      "www/acme-base.nix"
      "www/httpd.nix"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "24.05";

  # Allow other containers + the host to route through this host
  # onto the tailnet.
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    internalInterfaces = [ "host0" ];
    externalInterface = "tailscale0";
  };

  nixosContainer =
    {
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/tailscale:/var/lib/tailscale"
      ];
    };
}
