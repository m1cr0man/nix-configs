{ pkgs, config, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
  hashedPassword = "$6$nBss0j.JLsWvZ1VA$.iPwpuMp99C208zGtFpS6z0U9KchH0VBYFY6MUGaZvl.2CLUIZ8XG96A.gXVxOK.WJxky/fNB0k2BEkI06wqA1";
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
        extraGroups = [ "wheel" "git" "sockets" "systemd-journal" "users" ];
        packages = [
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
        extraGroups = [ "wheel" "systemd-journal" ];
        packages = [
          pkgs.lutris
          pkgs.prismlauncher
        ];
      };
    })
  ];
}
