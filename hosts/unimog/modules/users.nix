{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  nix.settings.trusted-users = [ "root" "lucas" ];

  users.groups = {
    lucas = { };
  };

  users.users = with lib.m1cr0man; lib.mkMerge [
    (makeNormalUser "lucas" {
      extraArgs.extraGroups = [ "wheel" ];
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq17Vz/gxVGDifkRFO6W5DJvJ5JnZ+DBq85W3UtRv82 lucas@ip-svr"
      ];
    })

  ];
}
