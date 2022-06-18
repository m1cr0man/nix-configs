{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  nix.settings.trusted-users = [ "root" "lucas" "zeus" ];

  users.groups = {
    lucas = { };
    zeus = { };
  };

  sops.secrets.zeus_password.neededForUsers = true;

  users.users = with lib.m1cr0man; lib.mkMerge [
    (makeNormalUser "lucas" {
      extraArgs = {
        extraGroups = [ "wheel" ];
        packages = [ pkgs.gnupg ];
      };
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq17Vz/gxVGDifkRFO6W5DJvJ5JnZ+DBq85W3UtRv82 lucas@ip-svr"
      ];
    })

    (makeNormalUser "zeus" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLjzYGz5SbhwxoaVuNQr1HWJuzqshVRB3QgV3qHdFvR id_ed25519_zeuspc.pem"
      ];
      extraArgs = {
        extraGroups = [ "wheel" ];
        passwordFile = config.sops.secrets.zeus_password.path;
      };
    })

  ];
}
