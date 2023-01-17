{ config, lib, pkgs, ... }:
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
    ];

  system.stateVersion = "22.11";

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  services.getty.autologinUser = lib.mkForce "root";
  # Enable sshd which gets disabled by netboot-minimal.nix
  systemd.services.sshd.wantedBy = lib.mkOverride 0 [ "multi-user.target" ];
}
