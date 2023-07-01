{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "gaming/minecraft"
      "gaming/openttd.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "22.11";

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
            25535
            25536
            # OpenTTD
            3979
          ];
      bindMounts = [
        "${stateDir}:/var/lib/gaming"
        "/home/mcadmins"
      ];
    };
}
