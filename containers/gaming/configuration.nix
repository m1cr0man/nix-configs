{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;

  sevendays_ports = [
    26900 26901 26902 26903 26904 26905
    27015 27016 27017 27018 27019 27020
  ];
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

  system.stateVersion = "25.11";

  nixosContainer =
    {
      forwardPorts =
        (builtins.map
          (port: { hostPort = port; containerPort = port; })
          ([
            # Minecraft
            25565
            25566
            25555
            25556
            25545
            25546
            # OpenTTD
            3979
            # 7DTD
          ] ++ sevendays_ports))
        ++ (builtins.map
          (port: { hostPort = port; containerPort = port; protocol = "udp"; })
          sevendays_ports);
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}:/var/lib/gaming"
        "/home/mcadmins"
      ];
    };
}
