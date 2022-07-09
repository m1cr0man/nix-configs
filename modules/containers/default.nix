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

    users.mutableUsers = false;
    users.allowNoPasswordLogin = true;

    networking = {
      useHostResolvConf = false;
      useDHCP = false;
      useNetworkd = true;
    };

    nixosContainer = {
      ephemeral = true;
      bridge = "br-containers";
      activation.strategy = lib.mkDefault "reload";
      bindMounts = [
        "/etc/ssh"
        "/var/lib/acme"
      ];
    };
  };
}
