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
      "www/tailscale.nix"
    ];

  system.stateVersion = "24.05";

  nixosContainer =
    {
      forwardPorts = [{ hostPort = port; containerPort = port; }];
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/tailscale:/var/lib/tailscale"
      ];
    };
}
