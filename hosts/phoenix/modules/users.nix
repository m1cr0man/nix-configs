{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  nix.settings.trusted-users = [ "root" "george" ];

  users.groups = {
    george = { };
  };

  sops.secrets.george_password.neededForUsers = true;
  sops.secrets.portfwd_guest_password.neededForUsers = true;

  users.mutableUsers = false;

  users.users = with lib.m1cr0man; lib.mkMerge [
    {
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ/+dK+9Y/QduSpNPoX/yfKYZazgUVwhs3DjH008U2C root@bgrs"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLjzYGz5SbhwxoaVuNQr1HWJuzqshVRB3QgV3qHdFvR id_ed25519_zeuspc.pem"
      ];
    }

    (makeNormalUser "george" {
      keys = rootKeys;
      extraArgs = {
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets.george_password.path;
      };
    })

    (makeNormalUser "portfwd-guest" {
      home = "/var/empty";
      group = "nogroup";
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMznnngrMCxW3bdpY32QPaAbgNGPp58A4t3tAnV1HdRW root@dhcpserver-tassie"
      ];
      extraArgs.hashedPasswordFile = config.sops.secrets.portfwd_guest_password.path;
    })
  ];
}
