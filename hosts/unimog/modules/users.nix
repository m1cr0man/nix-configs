{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  nix.settings.trusted-users = [ "root" "lucas" "zeus" ];

  users.groups = {
    anders = { };
    conor = { };
    lucas = { };
    zeus = { };
  };

  sops.secrets.zeus_password.neededForUsers = true;

  users.users = with lib.m1cr0man; lib.mkMerge [
    (makeNormalUser "anders" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuW9Vc1zz3qA++TpqLb6jTBx2ZfejO0uqrYt/tmGaEM ed25519-key-20210126"
      ];
    })

    (makeNormalUser "conor" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUlcCjTDPA9E4Bj04kdojvsjNnXXWKhJdmrum94zUdm Conor@LAPTOP-VA4JS3RE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3zyHMJERyIp7ydHBOM0JucdfFFqAFp/05iCk8L2540 conor@hisdesktop"
      ];
    })

    (makeNormalUser "lucas" {
      extraArgs = {
        extraGroups = [ "wheel" "acme" ];
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
