{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "monitoring/client"
      "gaming/openttd.nix"
    ];

  nixosContainer = {

      bindMounts = [
        "/var/lib/containers/test/data:/var/lib/data"
      ];
  };
}
