{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "gaming/minecraft"
      "management/ssh"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "23.05";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgKNU+q8EawCHKxGaxjtIME+Z3HcBJ5bNJVa6T6ypBy technae"
  ];

  environment.systemPackages = [ config.m1cr0man.minecraft-servers.technae.jre pkgs.htop pkgs.unzip ];

  nixosContainer =
    {
      forwardPorts = [
        { hostPort = 2424; containerPort = 22; }
      ] ++ (
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            # Minecraft
            25525
            25526
          ]
      );
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}:/var/lib/gaming"
        "/home/mcadmins"
      ];
    };
}
