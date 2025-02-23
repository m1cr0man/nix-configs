{ pkgs, config, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  users.mutableUsers = false;
  sops.secrets = {
    lucas_password.neededForUsers = true;
  };

  users.groups = {
    lucas = { };
  };

  users.users = with lib.m1cr0man; lib.mkMerge [
    { root.hashedPasswordFile = config.sops.secrets.lucas_password.path; }
    (makeNormalUser "lucas" {
      keys = rootKeys;
      extraArgs = {
        linger = true;
        extraGroups = [ "wheel" "git" "sockets" ];
        packages = [ pkgs.gnupg ];
        hashedPasswordFile = config.sops.secrets.lucas_password.path;
      };
    })
  ];
}
