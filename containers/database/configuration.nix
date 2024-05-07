{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "servers/postgresql.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "22.11";

  nixosContainer =
    {
      bindMounts = [
        "${stateDir}/postgresql:/var/lib/postgresql"
      ];
    };
}
