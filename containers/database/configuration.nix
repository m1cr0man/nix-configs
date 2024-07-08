{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "monitoring/client"
      "servers/postgresql.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "24.05";

  nixosContainer =
    {
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/postgresql:/var/lib/postgresql"
      ];
    };
}
