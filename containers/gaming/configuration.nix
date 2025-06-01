{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "monitoring/client"
      "gaming/minecraft"
      "gaming/openttd.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "25.05";

  nixosContainer =
    {
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            # Minecraft
            25565
            25566
            25555
            25556
            25545
            25546
            # OpenTTD
            3979
          ];
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}:/var/lib/gaming"
        "/home/mcadmins"
      ];
    };
}
