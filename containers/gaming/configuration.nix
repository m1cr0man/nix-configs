{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;

  multiproto_ports = [
    # Seven days to die
    # 26900 26901 26902 26903 26904 26905
    # 27015 27016 27017 27018 27019 27020
    # Satisfactory
    7777 8888
  ];
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

  system.stateVersion = "26.11";

  environment.systemPackages = [ pkgs.inetutils pkgs.socat pkgs.steamcmd ];

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
          ] ++ multiproto_ports))
        ++ (builtins.map
          (port: { hostPort = port; containerPort = port; protocol = "udp"; })
          multiproto_ports);
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}:/var/lib/gaming"
        "/home/mcadmins"
      ];
    };
}
