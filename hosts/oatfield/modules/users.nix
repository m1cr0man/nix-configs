{ pkgs, config, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
  hashedPassword = "$6$iWiYqbOg0OsHwpSM$oAOa9xG4I2EPO7.TDbw7RSpb4mTX6M73pFshXpdn8PNm8wwSz0eVHUcqBsqZrqe6d3q/EAzE3bt4dZyq8CI7c.";
  hashedPasswordMeghan = "$6$uQBEIFHwFNlnFqCH$YaC4TSJwbda36rDVVG0qG6vMzlel2GB4B8HAR3.SefIknHqcqYCsaSTHruo0B/qOpDw0CEbgCAls0jQ9iSyHV0";
in
{
  users.mutableUsers = false;

  nix.settings.trusted-users = [ "root" "lucas" ];

  users.groups = {
    lucas = {
      gid = 1000;
    };
    meghan = { };
  };

  users.users = with lib.m1cr0man; lib.mkMerge [
    { root.hashedPassword = hashedPassword; }
    (makeNormalUser "lucas" {
      description = "Lucas";
      keys = rootKeys;
      extraArgs = {
        uid = 1000;
        inherit hashedPassword;
        linger = true;
        extraGroups = [ "wheel" "git" "sockets" "systemd-journal" "users" "networkmanager" ];
        packages = [
          pkgs.efibootmgr
          pkgs.sbctl
          pkgs.gnupg
          pkgs.remmina
          pkgs.easyeffects
          pkgs.obsidian
          pkgs.orca-slicer
          # Gaming
          pkgs.lutris
          pkgs.prismlauncher
        ];
      };
    })
    (makeNormalUser "meghan" {
      description = "Meghan";
      keys = rootKeys;
      extraArgs = {
        hashedPassword = hashedPasswordMeghan;
        extraGroups = [ "systemd-journal" "users" "networkmanager" ];
        packages = [
          pkgs.lutris
          pkgs.prismlauncher
        ];
      };
    })
  ];
}
