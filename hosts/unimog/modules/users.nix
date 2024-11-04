{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  nix.settings.trusted-users = [ "root" "lucas" "zeus" ];

  users.groups = {
    anders = { };
    conor = { };
    patrick = { };
    adam = { };
    lucas = { };
    zeus = { };
    git = { };
  };

  sops.secrets.root_password.neededForUsers = true;
  sops.secrets.lucas_password.neededForUsers = true;
  sops.secrets.zeus_password.neededForUsers = true;
  sops.secrets.portfwd_guest_password.neededForUsers = true;

  users.mutableUsers = false;
  users.users = with lib.m1cr0man; lib.mkMerge [
    { root.hashedPasswordFile = config.sops.secrets.root_password.path; }
    (makeNormalUser "anders" {
      extraArgs.linger = true;
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuW9Vc1zz3qA++TpqLb6jTBx2ZfejO0uqrYt/tmGaEM ed25519-key-20210126"
      ];
    })

    (makeNormalUser "conor" {
      extraArgs.linger = true;
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUlcCjTDPA9E4Bj04kdojvsjNnXXWKhJdmrum94zUdm Conor@LAPTOP-VA4JS3RE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3zyHMJERyIp7ydHBOM0JucdfFFqAFp/05iCk8L2540 conor@hisdesktop"
      ];
    })

    (makeNormalUser "patrick" {
      extraArgs.linger = true;
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6YhnTHgxs3lWEaldAJeQo4SNlHEX3WjJ3jFnxLp4bi Patrick@Mac-mini.local"
      ];
    })

    (makeNormalUser "lucas" {
      extraArgs = {
        linger = true;
        extraGroups = [ "wheel" "acme" "git" "sockets" ];
        packages = [ pkgs.gnupg ];
        hashedPasswordFile = config.sops.secrets.lucas_password.path;
      };
      keys = rootKeys;
    })

    (makeNormalUser "adam" {
      extraArgs = {
        extraGroups = [ "git" "sockets" ];
        packages = [ pkgs.gnupg ];
      };
      keys = rootKeys;
    })

    (makeNormalUser "zeus" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLjzYGz5SbhwxoaVuNQr1HWJuzqshVRB3QgV3qHdFvR id_ed25519_zeuspc.pem"
      ];
      extraArgs = {
        extraGroups = [ "wheel" "git" ];
        hashedPasswordFile = config.sops.secrets.zeus_password.path;
      };
    })

    (makeNormalUser "portfwd-guest" {
      home = "/var/empty";
      group = "nogroup";
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMznnngrMCxW3bdpY32QPaAbgNGPp58A4t3tAnV1HdRW root@dhcpserver-tassie"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpdRenXTF6HHbgwNdu++dvlucOPX5ZC8Zb+/HXzgoHo admin@feefy"
      ];
      extraArgs.hashedPasswordFile = config.sops.secrets.portfwd_guest_password.path;
    })
  ];
}
