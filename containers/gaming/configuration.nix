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
            25555
            25545
            25535
            25525
            # OpenTTD
            3979
          ];
      bindMounts = [
        "${stateDir}:/var/lib/gaming"
        "${stateDir}/zram0:/var/lib/gaming/zram0"
        "${stateDir}/zram1:/var/lib/gaming/zram1"
        "/home/mcadmins"
      ];
    };
}
