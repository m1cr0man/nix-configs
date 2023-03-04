{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  nix.settings.trusted-users = [ "root" "deck" ];

  users.groups = {
    deck = { };
  };

  sops.secrets.deck_password.neededForUsers = true;

  users.users = with lib.m1cr0man; lib.mkMerge [
    (makeNormalUser "deck" {
      description = "Steam Deck";
      extraArgs = {
        extraGroups = [ "wheel" "networkmanager" "systemd-journal" ];
        passwordFile = config.sops.secrets.deck_password.path;
      };
      keys = rootKeys;
    })
  ];
}
