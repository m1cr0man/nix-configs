{ pkgs, config, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
  # First tarot card, lowercase
  hashedPassword = "$6$16OxOzH7pf5cSSNM$TDCXaU2wb60tvVFK8TzJyZg.cpJ4Q2IaQYCWei1a1dvKUyfdQBhfueGmSe3xacnSVGr24avtuAexPZLrrkiLw.";
in
{
  users.mutableUsers = false;

  nix.settings.trusted-users = [ "root" "meghan" ];

  services.displayManager.autoLogin = {
    enable = true;
    user = "meghan";
  };

  users.groups = {
    meghan = {
      gid = 1000;
    };
  };

  users.users = with lib.m1cr0man; lib.mkMerge [
    { root.hashedPassword = hashedPassword; }
    (makeNormalUser "meghan" {
      description = "Meghan";
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
  ];
}
