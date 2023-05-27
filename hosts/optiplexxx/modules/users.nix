{ config, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  users.mutableUsers = false;

  sops.secrets.zeus_password.neededForUsers = true;

  nix.settings.trusted-users = [ "root" "zeus" ];

  users.groups = {
    lucasguest = { };
    zeus = { };
  };

  users.users = with lib.m1cr0man; lib.mkMerge [
    (makeNormalUser "lucasguest" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLjzYGz5SbhwxoaVuNQr1HWJuzqshVRB3QgV3qHdFvR id_ed25519_zeuspc.pem"
      ];
      extraArgs.extraGroups = [ "wheel" ];
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
