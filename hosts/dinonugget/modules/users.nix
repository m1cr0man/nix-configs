{ pkgs, config, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
  hashedPassword = "$6$nBss0j.JLsWvZ1VA$.iPwpuMp99C208zGtFpS6z0U9KchH0VBYFY6MUGaZvl.2CLUIZ8XG96A.gXVxOK.WJxky/fNB0k2BEkI06wqA1";
in
{
  users.mutableUsers = false;

  users.groups = {
    lucas = { };
  };

  users.users = with lib.m1cr0man; lib.mkMerge [
    { root.hashedPassword = hashedPassword; }
    (makeNormalUser "lucas" {
      description = "Lucas";
      keys = rootKeys;
      extraArgs = {
        inherit hashedPassword;
        linger = true;
        extraGroups = [ "wheel" "git" "sockets" ];
        packages = [
          pkgs.gnupg
          pkgs.remmina
          pkgs.easyeffects
          # Gaming
          pkgs.lutris
          pkgs.bottles
          pkgs.prismlauncher
        ];
      };
    })
  ];
}
