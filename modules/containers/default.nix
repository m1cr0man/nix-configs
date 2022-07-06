{ lib, modulesPath, ... }:
let
  inherit (lib) types mkOption;
  containerOptions = (import (modulesPath + "/virtualisation/containers-next/container-options.nix")
    {
      inherit lib;
    }).options;
in
{
  options.nixosContainer = builtins.removeAttrs containerOptions [ "system-config" "nixpkgs" ];

  config = {
    boot.isContainer = true;
    networking = {
      useHostResolvConf = false;
      useDHCP = false;
      useNetworkd = true;
    };
    nixosContainer.activation.strategy = lib.mkDefault "restart";
  };
}
